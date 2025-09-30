import NIO

struct OfflineConnectionRequest1: RakNet.OfflinePacket {
    let packetType: RakNet.PacketType = .OFFLINE_CONNECTION_REQUEST_1
    let magic: UInt128 // 16 bytes
    let protocolVersion: UInt8
    let padding: ByteBuffer
    var mtu: UInt16 { UInt16(padding.readableBytes + 46) /* packet type + magic + protocol version + 8-byte UDP header + 20-byte IPv4 */ }

    init(from buffer: ByteBuffer) throws {
        var buffer = buffer

        self.magic = buffer.readMagic() ?? 0
        self.protocolVersion = buffer.readProtocolVersion() ?? 0
        self.padding = buffer
    }
}