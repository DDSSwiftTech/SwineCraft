import NIOCore

struct UnconnectedPongPacket: RakNetPacket {
    var packetType: RakNetPacketType = .UNCONNECTED_PONG
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
}