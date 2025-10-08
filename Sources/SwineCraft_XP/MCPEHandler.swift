import NIO
import SwakNet

class MCPEHandler: ChannelInboundHandler, @unchecked Sendable {
    typealias InboundIn = AddressedEnvelope<ByteBuffer>
    typealias OutboundOut = AddressedEnvelope<ByteBuffer>

    let stateHandler = MCPEStateHandler()

    func userInboundEventTriggered(context: ChannelHandlerContext, event: Any) {
        let event = event as! RakNetEvent

        switch event {
            case .DISCONNECTED(let source, let reason):
                self.stateHandler.discardState(source: source)

                print("Disconnected: \(reason)")
        }
    }

    func errorCaught(context: ChannelHandlerContext, error: any Error) {}

    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        let inboundEnvelope = self.unwrapInboundIn(data)
        var buffer = inboundEnvelope.data
        let sourceAddress = RakNetAddress(from: inboundEnvelope.remoteAddress)!

        let old_buffer = buffer

        if !self.stateHandler.stateActive(source: sourceAddress) { // TODO: This will need a revisit
            let _ = buffer.readBytes(length: 1) // putting the length byte here, don't need it
        } else {
            guard let compressionMethod = CompressionMethod(rawValue: 0xFF00 | dump(UInt16(buffer.readInteger()! as UInt8))) else {
                print("bad compression method")

                return
            }

            switch compressionMethod {
                case .None:
                    let bufferLength: VarInt = buffer.readVarInt()

                    print(bufferLength)

                    buffer = ByteBuffer(bytes: buffer.readBytes(length: Int(bufferLength.backingInt))!)
                default:
                    return // We will have to handle ZLIB and Snappy compression, but lets just not for now and come back to this later...
            }
        }

        switch MCPEPacketType(rawValue: buffer.readInteger()!) {
            case .REQUEST_NETWORK_SETTINGS:
                guard let packet = try? RequestNetworkSettingsPacket(from: &buffer) else {
                    return
                }

                self.stateHandler.initializeState(source: sourceAddress, version: packet.protocolVersion)

                let responsePacket = NetworkSettingsPacket(
                    compressionThreshold: 0,
                    compressionMethod: .None,
                    clientThrottleEnabled: false,
                    clientThrottleThreshold: 0,
                    clientThrottleScalar: 0
                )

                let data = try! responsePacket.encode()

                context.write(self.wrapOutboundOut(AddressedEnvelope(remoteAddress: inboundEnvelope.remoteAddress, data: ByteBuffer([0xfe] + VarInt(integerLiteral: Int32(data.readableBytes)).encode().readableBytesView + data.readableBytesView))), promise: nil)
            case .LOGIN:
                guard let packet = try? LoginPacket(from: &buffer) else {
                    return
                }

                print("RECEIVED LOGIN PACKET")

                self.stateHandler.setLoginPacket(packet, forSource: sourceAddress)

                let responsePacket = PlayStatusPacket(status: .LOGIN_SUCCESS)
                
                let data = try! responsePacket.encode()

                context.write(self.wrapOutboundOut(AddressedEnvelope(remoteAddress: inboundEnvelope.remoteAddress, data: ByteBuffer([0xfe, 0xFF] + VarInt(integerLiteral: Int32(data.readableBytes)).encode().readableBytesView + data.readableBytesView))), promise: nil)
            case .CLIENT_CACHE_STATUS:
                guard let packet = try? ClientCacheStatusPacket(from: &buffer) else {
                    return
                }

                self.stateHandler.setClientCacheSupported(packet.cachingStatus, forSource: sourceAddress)

                print("RECEIVED CLIENT CACHE STATUS")

                let responsePacket = packet // lets just send it back, we want to mimic server support

                let data = try! responsePacket.encode()

                context.write(self.wrapOutboundOut(AddressedEnvelope(remoteAddress: inboundEnvelope.remoteAddress, data: ByteBuffer([0xfe, 0xFF] + VarInt(integerLiteral: Int32(data.readableBytes)).encode().readableBytesView + data.readableBytesView))), promise: nil)
            case nil:
                print("UNKNOWN PACKET TYPE \(old_buffer)")
            default: 
                print("UNIMEPLEMENTED PACKET TYPE \(old_buffer)")
        }
    }
}