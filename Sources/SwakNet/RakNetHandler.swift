import NIO
import Foundation

extension ChannelHandlerContext: @retroactive @unchecked Sendable {}

extension RakNet {
    public final class Handler: ChannelInboundHandler, @unchecked Sendable {
        public typealias InboundIn = AddressedEnvelope<ByteBuffer>
        public typealias InboundOut = AddressedEnvelope<ByteBuffer>
        public typealias OutboundOut = AddressedEnvelope<ByteBuffer>

        private let SERVER_ID_STRING: String

        init(SERVER_ID_STRING: String) {
            self.SERVER_ID_STRING = SERVER_ID_STRING
        }

        public func channelActive(context: ChannelHandlerContext) {
            // print("CHANNEL ACTIVE")
        }

        public func channelRead(context: ChannelHandlerContext, data: NIOAny) {
            let inboundEnvelope = self.unwrapInboundIn(data)

            guard inboundEnvelope.data.readableBytes > 0 else {
                return
            }

            var buffer = inboundEnvelope.data

            self.processPacketBuffer(&buffer, context: context, inboundEnvelope: inboundEnvelope)
        }

        private func processPacketBuffer(_ buffer: inout ByteBuffer, context: ChannelHandlerContext, inboundEnvelope: InboundIn) {
            let old_data = buffer
            let packetType = RakNet.PacketType(rawValue: buffer.readInteger() ?? 0 )
            let sourceAddress = RakNet.Address(from: inboundEnvelope.remoteAddress)!

            switch packetType {
                case .UNCONNECTED_PING_0:
                    guard let packet = try? UnconnectedPingPacket(from: &buffer) else {
                        return
                    }
                    
                    let responsePacket = UnconnectedPongPacket(
                        time: RakNet.Config.shared.timeSinceLaunch,
                        guid: packet.guid,
                        magic: packet.magic,
                        serverIDString: self.SERVER_ID_STRING
                    )

                    context.write(self.wrapOutboundOut(Self.OutboundOut(remoteAddress: inboundEnvelope.remoteAddress, data: try! responsePacket.encode())), promise: nil)
                case .OFFLINE_CONNECTION_REQUEST_1:
                    guard let packet = try? OfflineConnectionRequest1(from: buffer) else {
                        return
                    }
                    
                    context.eventLoop.makeFutureWithTask {
                        await StateHandler.shared.initializeState(clientTime: 0, connectionID: Address(from: inboundEnvelope.remoteAddress)!)
                        await StateHandler.shared.setConnectionMTU(connectionID: Address(from: inboundEnvelope.remoteAddress)!, mtu: packet.mtu)
                    }.whenComplete { _ in
                        let responsePacket = OfflineConnectionResponse1(magic: packet.magic, serverHasSecurity: false, mtu: packet.mtu)
                        context.write(self.wrapOutboundOut(Self.OutboundOut(remoteAddress: inboundEnvelope.remoteAddress, data: try! responsePacket.encode())), promise: nil)
                    }                    
                case .OFFLINE_CONNECTION_REQUEST_2:
                    guard let packet = try? OfflineConnectionRequest2(from: buffer) else {
                        return
                    }

                    context.eventLoop.makeFutureWithTask {
                        await StateHandler.shared.getConnectionMTU(connectionID: Address(from: inboundEnvelope.remoteAddress)!)!
                    }.whenComplete { result in
                        let responsePacket = OfflineConnectionResponse2(
                            magic: packet.magic,
                            clientAddress: sourceAddress,
                            mtuSize: try! result.get()
                        )

                        context.write(self.wrapOutboundOut(Self.OutboundOut(remoteAddress: inboundEnvelope.remoteAddress, data: try! responsePacket.encode())), promise: nil)
                    }
                case .DATA_PACKET_0, .DATA_PACKET_1, .DATA_PACKET_2, .DATA_PACKET_3, .DATA_PACKET_4, .DATA_PACKET_5, .DATA_PACKET_6, .DATA_PACKET_7, .DATA_PACKET_8, .DATA_PACKET_9, .DATA_PACKET_A, .DATA_PACKET_B, .DATA_PACKET_C, .DATA_PACKET_D, .DATA_PACKET_E, .DATA_PACKET_F:
                    guard let packet = try? DataPacket(from: &buffer) else {
                        return
                    }

                    let responsePacket = ACKPacket(
                        sequenceNumber: .single(packet.sequenceNumber)
                    )

                    context.write(self.wrapOutboundOut(Self.OutboundOut(remoteAddress: inboundEnvelope.remoteAddress, data: try! responsePacket.encode())), promise: nil)

                    context.eventLoop.makeFutureWithTask {
                        await StateHandler.shared.decapsulateDataPacket(packet: packet, connectionID: sourceAddress)
                    }.whenComplete { result in
                        let decapsulationResult = try! result.get()

                        for decapResultItem in decapsulationResult {
                            switch decapResultItem {
                                case .failure(let error):
                                    print(error)
                                case .success(var decapsulatedBuffer):

                                    self.processPacketBuffer(&decapsulatedBuffer, context: context, inboundEnvelope: inboundEnvelope)
                            }
                        }
                    }
                case .ONLINE_CONNECTION_REQUEST:
                    guard let packet = try? ConnectionRequestPacket(from: &buffer) else {
                    // let activeStateStruct = await StateHandler.shared.activeConnectionState[sourceAddress] else {
                        return
                    }
                    
                    context.eventLoop.makeFutureWithTask {
                        await StateHandler.shared.setClientTime(connectionID: Address(from: inboundEnvelope.remoteAddress)!, time: packet.time)
                    }.map {
                        return ConnectionRequestAcceptedPacket(
                            clientAddress: sourceAddress,
                            requestTime: packet.time,
                            time: RakNet.Config.shared.timeSinceLaunch
                        )
                    }.flatMapWithEventLoop { packet, loop in
                        loop.makeFutureWithTask {
                            await StateHandler.shared.encapsulate(packets: [packet], connectionID: sourceAddress)
                        }
                    }.whenComplete { result in
                        context.write(self.wrapOutboundOut(Self.OutboundOut(remoteAddress: inboundEnvelope.remoteAddress, data: try! result.get().encode())), promise: nil)
                    }
                case .ACK:
                    guard let packet = try? ACKPacket(from: &buffer) else {
                        return
                    }

                    // Remove ACKed packets as they will not need to be retransmitted

                    switch packet.sequenceNumber {
                        case .single(let seq):
                            let _ = context.eventLoop.makeFutureWithTask {
                                await StateHandler.shared.removeAckedPacket(seqNum: seq, connectionID: sourceAddress)
                            }
                        case .range(let seqRange):
                            for seq in seqRange {
                                let _ = context.eventLoop.makeFutureWithTask {
                                    await StateHandler.shared.removeAckedPacket(seqNum: seq, connectionID: Address(from: inboundEnvelope.remoteAddress)!)
                                }
                            }
                    }
                case .NACK:
                    guard let packet = try? NACKPacket(from: &buffer) else {
                        return
                    }

                    // Retransmit NACKed packets

                    switch packet.sequenceNumber {
                        case .single(let seq):
                                context.eventLoop.makeFutureWithTask({
                                    await StateHandler.shared.getUnackedPacket(seqNum: seq, connectionID: sourceAddress)
                                }).whenComplete { result in
                                    context.write(self.wrapOutboundOut(Self.OutboundOut(remoteAddress: inboundEnvelope.remoteAddress, data: try! result.get()!.encode())), promise: nil)
                                }
                        case .range(let seqRange):
                            for seq in seqRange {
                                context.eventLoop.makeFutureWithTask({
                                    await StateHandler.shared.getUnackedPacket(seqNum: seq, connectionID: sourceAddress)
                                }).whenComplete { result in
                                        context.write(self.wrapOutboundOut(Self.OutboundOut(remoteAddress: inboundEnvelope.remoteAddress, data: try! result.get()!.encode())), promise: nil)
                                }
                            }
                        }
                case .CLIENT_DISCONNECT:
                    context.eventLoop.makeFutureWithTask({
                        await StateHandler.shared.discardState(connectionID: sourceAddress)
                    }).whenComplete { _ in
                        let packet = DisconnectPacket()

                        print("Received Disconnect: \(packet)")

                        context.fireUserInboundEventTriggered(RakNetEvent.DISCONNECTED(source: sourceAddress, reason: "Client-side disconnect"))
                    }
                case .CLIENT_HANDSHAKE:
                    guard let packet = try? ClientHandshakePacket(from: &buffer) else {
                        return
                    }

                    let _ = context.eventLoop.makeFutureWithTask({
                        await StateHandler.shared.setClientAddresses(connectionID: sourceAddress, addresses: packet.clientAddresses)
                    })
                case .CONNECTED_PING:
                    guard let packet = try? ConnectedPingPacket(from: &buffer) else {
                        return
                    }

                    let responsePacket = ConnectedPongPacket(clientTime: packet.time, serverTime: Int64(RakNet.Config.shared.timeSinceLaunch))
                    
                    context.eventLoop.makeFutureWithTask {
                        try await StateHandler.shared.encapsulate(packets: [responsePacket], connectionID: sourceAddress).encode()
                    }.whenComplete { result in
                        context.write(self.wrapOutboundOut(Self.OutboundOut(remoteAddress: inboundEnvelope.remoteAddress, data: try! result.get())), promise: nil)
                    }
                case .GAME_PACKET:
                    print("RECEIVED GAME PACKET")
                    context.fireChannelRead(self.wrapInboundOut(OutboundOut(remoteAddress: inboundEnvelope.remoteAddress, data: buffer))) // for Minecraft, pass raw data, let it handle its own packets
                    buffer.clear()
                default:
                    print("UNHANDLED PACKET \(old_data.readableBytesView)")
                    buffer.clear()
                    return
            }
        }

        public func channelReadComplete(context: ChannelHandlerContext) {
            context.flush()
        }

        public func handlerAdded(context: ChannelHandlerContext) {
            print("HANDLER ADDED")
            // print(context)
        }
        public func channelInactive(context: ChannelHandlerContext) {
            print("HANDLER INACTIVE")
        }

        public func channelRegistered(context: ChannelHandlerContext) {
            print("CHANNEL REGISTERED")
        }

        public func errorCaught(context: ChannelHandlerContext, error: any Swift.Error) {
            print(context, error)
        }

        public func userInboundEventTriggered(context: ChannelHandlerContext, event: Any) {
            print(context, event)
        }

        func errorCaught(context: ChannelHandlerContext, error: Error) {
            print(context, error)
        }

        public func channelUnregistered(context: ChannelHandlerContext) {
            print("CHANNEL UNREGISTERED")
        }

        deinit {
            print("Handler deinitializing")
        }
    }
} 