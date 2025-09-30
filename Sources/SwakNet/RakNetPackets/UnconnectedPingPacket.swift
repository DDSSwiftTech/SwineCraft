import NIO

struct UnconnectedPingPacket: RakNet.Packet {
    var packetType: RakNet.PacketType = .UNCONNECTED_PING_0
    var time: UInt64
    var magic: UInt128 // 16 bytes
    var guid: UInt64

    init(from buffer: inout ByteBuffer) throws {
        self.time = buffer.readTime() ?? 0
        self.magic = buffer.readMagic() ?? 0
        self.guid = buffer.readGUID() ?? 0
    }
}