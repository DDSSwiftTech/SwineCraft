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

    func errorCaught(context: ChannelHandlerContext, error: any Error) {
    }
    
    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        let inboundEnvelope = self.unwrapInboundIn(data)
        var buffer = inboundEnvelope.data

        let old_buffer = buffer

        // if !self.stateHandler.stateActive(source: RakNet.Address(from: inboundEnvelope.remoteAddress)!) { // TODO: This will need a revisit
            let _ = buffer.readBytes(length: 1) // putting the length byte here, don't need it
        // }

        switch MCPEPacketType(rawValue: buffer.readInteger()!) {
            case .REQUEST_NETWORK_SETTINGS:
                guard let packet = try? RequestNetworkSettingsPacket(from: &buffer) else {
                    return
                }

                self.stateHandler.initializeState(source: RakNet.Address(from: inboundEnvelope.remoteAddress)!, version: packet.protocolVersion)

                let responsePacket = NetworkSettingsPacket(
                    compressionThreshold: 256,
                    compressionMethod: .ZLib,
                    clientThrottleEnabled: false,
                    clientThrottleThreshold: 0,
                    clientThrottleScalar: 0
                )

                let data = try! responsePacket.encode()

                context.write(self.wrapOutboundOut(AddressedEnvelope(remoteAddress: inboundEnvelope.remoteAddress, data: ByteBuffer([0xfe] + MCPE.VarInt(integerLiteral: Int32(data.readableBytes)).encode().readableBytesView + data.readableBytesView))), promise: nil)
            case nil:
                print("UNKNOWN PACKET TYPE \(old_buffer)")
            default: 
                print("UNIMEPLEMENTED PACKET TYPE \(old_buffer)")
        }
    }
}