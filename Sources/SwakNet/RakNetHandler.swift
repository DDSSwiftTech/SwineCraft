import NIO
import Foundation

extension RakNet {
    public final class Handler: ChannelInboundHandler, @unchecked Sendable {
        public typealias InboundIn = AddressedEnvelope<ByteBuffer>
        public typealias InboundOut = ByteBuffer
        public typealias OutboundOut = AddressedEnvelope<ByteBuffer>

        private let SERVER_ID_STRING: String
        private let stateHandler = RakNet.StateHandler()

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

            processPacketBuffer(&buffer, context: context, inboundEnvelope: inboundEnvelope)
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

                    self.stateHandler.initializeState(clientTime: 0, connectionID: sourceAddress)

                    self.stateHandler.setConnectionMTU(connectionID: sourceAddress, mtu: packet.mtu)

                    let responsePacket = OfflineConnectionResponse1(magic: packet.magic, serverHasSecurity: false, mtu: self.stateHandler.getConnectionMTU(connectionID: sourceAddress)!)

                    context.write(self.wrapOutboundOut(Self.OutboundOut(remoteAddress: inboundEnvelope.remoteAddress, data: try! responsePacket.encode())), promise: nil)
                case .OFFLINE_CONNECTION_REQUEST_2:
                    guard let packet = try? OfflineConnectionRequest2(from: buffer) else {
                        return
                    }

                    let responsePacket = OfflineConnectionResponse2(
                        magic: packet.magic,
                        clientAddress: sourceAddress,
                        mtuSize: self.stateHandler.getConnectionMTU(connectionID: sourceAddress)!
                    )

                    context.write(self.wrapOutboundOut(Self.OutboundOut(remoteAddress: inboundEnvelope.remoteAddress, data: try! responsePacket.encode())), promise: nil)
                case .DATA_PACKET_0, .DATA_PACKET_1, .DATA_PACKET_2, .DATA_PACKET_3, .DATA_PACKET_4, .DATA_PACKET_5, .DATA_PACKET_6, .DATA_PACKET_7, .DATA_PACKET_8, .DATA_PACKET_9, .DATA_PACKET_A, .DATA_PACKET_B, .DATA_PACKET_C, .DATA_PACKET_D, .DATA_PACKET_E, .DATA_PACKET_F:
                    guard let packet = try? DataPacket(from: &buffer) else {
                        return
                    }

                    let responsePacket = ACKPacket(
                        sequenceNumber: .single(packet.sequenceNumber)
                    )

                    context.write(self.wrapOutboundOut(Self.OutboundOut(remoteAddress: inboundEnvelope.remoteAddress, data: try! responsePacket.encode())), promise: nil)

                    let decapsulationResult = self.stateHandler.decapsulateDataPacket(packet: packet, connectionID: sourceAddress)

                    for decapResultItem in decapsulationResult {
                        switch decapResultItem {
                            case .failure(let error):
                                print(error)
                            case .success(var decapsulatedBuffer):

                                self.processPacketBuffer(&decapsulatedBuffer, context: context, inboundEnvelope: inboundEnvelope)
                        }
                    }
                case .ONLINE_CONNECTION_REQUEST:
                    guard let packet = try? ConnectionRequestPacket(from: &buffer),
                    let activeStateStruct = self.stateHandler.activeConnectionState[sourceAddress] else {
                        return
                    }

                    self.stateHandler.activeConnectionState[sourceAddress]?.clientTime = packet.time

                    let responseRawPacket = ConnectionRequestAcceptedPacket(
                        clientAddress: activeStateStruct.connectionID as RakNet.Address,
                        requestTime: packet.time,
                        time: RakNet.Config.shared.timeSinceLaunch
                    )

                    let responsePacket = self.stateHandler.encapsulate(packets: [responseRawPacket], connectionID: sourceAddress)

                    context.write(self.wrapOutboundOut(Self.OutboundOut(remoteAddress: inboundEnvelope.remoteAddress, data: try! responsePacket.encode())), promise: nil)
                case .ACK:
                    guard let packet = try? ACKPacket(from: &buffer) else {
                        return
                    }

                    // Remove ACKed packets as they will not need to be retransmitted

                    switch packet.sequenceNumber {
                        case .single(let seq):
                            self.stateHandler.removeAckedPacket(seqNum: seq, connectionID: sourceAddress)
                        case .range(let seqRange):
                            for seq in seqRange {
                                self.stateHandler.removeAckedPacket(seqNum: seq, connectionID: sourceAddress)
                            }
                    }
                case .NACK:
                    guard let packet = try? NACKPacket(from: &buffer) else {
                        return
                    }

                    // Retransmit NACKed packets

                    switch packet.sequenceNumber {
                        case .single(let seq):
                            guard let nackedPacket = self.stateHandler.getUnackedPacket(seqNum: seq, connectionID: sourceAddress) else {
                                return
                            }

                            context.write(self.wrapOutboundOut(Self.OutboundOut(remoteAddress: inboundEnvelope.remoteAddress, data: try! nackedPacket.encode())), promise: nil)
                        case .range(let seqRange):
                            for seq in seqRange {
                                guard let nackedPacket = self.stateHandler.getUnackedPacket(seqNum: seq, connectionID: sourceAddress) else {
                                    return
                                }

                                context.write(self.wrapOutboundOut(Self.OutboundOut(remoteAddress: inboundEnvelope.remoteAddress, data: try! nackedPacket.encode())), promise: nil)
                            }
                    }
                case .CLIENT_DISCONNECT:
                    let packet = DisconnectPacket()

                    self.stateHandler.discardState(connectionID: sourceAddress)

                    print("Received Disconnect: \(packet)")
                case .CLIENT_HANDSHAKE:
                    guard let packet = try? ClientHandshakePacket(from: &buffer) else {
                        return
                    }

                    self.stateHandler.setClientAddresses(connectionID: sourceAddress, addresses: packet.clientAddresses)
                case .CONNECTED_PING:
                    guard let packet = try? ConnectedPingPacket(from: &buffer) else {
                        return
                    }

                    let responsePacket = ConnectedPongPacket(clientTime: packet.time, serverTime: Int64(RakNet.Config.shared.timeSinceLaunch))
                    
                    context.write(self.wrapOutboundOut(Self.OutboundOut(remoteAddress: inboundEnvelope.remoteAddress, data: try! self.stateHandler.encapsulate(packets: [responsePacket], connectionID: sourceAddress).encode())), promise: nil)
                case .GAME_PACKET:
                    print("RECEIVED GAME PACKET")
                    context.fireChannelRead(self.wrapInboundOut(buffer)) // for Minecraft, pass raw data, let it handle its own packets
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

        public func channelUnregistered(context: ChannelHandlerContext) {
            print("CHANNEL UNREGISTERED")
        }

        deinit {
            print("Handler deinitializing")
        }
    }
} 