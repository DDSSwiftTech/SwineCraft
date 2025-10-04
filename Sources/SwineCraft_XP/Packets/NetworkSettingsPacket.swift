import NIOCore

struct NetworkSettingsPacket: MCPEPacket {
    var packetType: MCPEPacketType = .NETWORK_SETTINGS

    let compressionThreshold: UInt16
    let compressionMethod: CompressionMethod
    let clientThrottleEnabled: Bool
    let clientThrottleThreshold: UInt8
    let clientThrottleScalar: Float

    func encode() throws -> ByteBuffer {
        var buffer = ByteBuffer()

        buffer.writeInteger(self.packetType.rawValue)
        buffer.writeInteger(UInt8(0x01)) // Don't know what this is...
        buffer.writeInteger(self.compressionThreshold)
        buffer.writeInteger(self.compressionMethod.rawValue)
        buffer.writeInteger(UInt8(self.clientThrottleEnabled ? 1 : 0))
        buffer.writeInteger(self.clientThrottleThreshold)
        var clientThrottleScalar = self.clientThrottleScalar

        let _ = withUnsafeBytes(of: &clientThrottleScalar) { ptr in
            buffer.writeBytes(ptr)
        }

        return buffer
    }
}