import NIOCore

struct UnconnectedPongPacket: RakNet.Packet {
    var packetType: RakNet.PacketType = .UNCONNECTED_PONG
    var time: UInt64
    var guid: UInt64
    var magic: UInt128
    var serverIDString: String

    init(time: UInt64, guid: UInt64, magic: UInt128, serverIDString: String) {
        self.time = time
        self.guid = guid
        self.magic = magic
        self.serverIDString = serverIDString
    }

    init(from buffer: inout ByteBuffer) throws {
        self.time = buffer.readTime() ?? 0
        self.guid = buffer.readGUID() ?? 0
        self.magic = buffer.readMagic() ?? 0
        self.serverIDString = buffer.readServerIDString() ?? ""
    }

    func encode() throws -> ByteBuffer {
        var buffer = ByteBuffer()

        buffer.writeInteger(self.packetType.rawValue)
        buffer.writeInteger(self.time)
        buffer.writeInteger(self.guid)
        buffer.writeInteger(self.magic)
        buffer.writeInteger(UInt16(self.serverIDString.count))
        buffer.writeBytes(self.serverIDString.map {$0.asciiValue!})

        return buffer
    }
}