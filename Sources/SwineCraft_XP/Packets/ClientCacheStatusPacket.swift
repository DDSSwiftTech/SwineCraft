import NIOCore

struct ClientCacheStatusPacket: MCPEPacket {
    var packetType: MCPEPacketType = .CLIENT_CACHE_STATUS

    let cachingStatus: Bool

    init(from buffer: inout ByteBuffer) throws {
        self.cachingStatus = buffer.readBytes(length: 1)![0] == 1
    }

    func encode() throws -> ByteBuffer {
        var buffer = ByteBuffer()

        buffer.writeInteger(self.packetType.rawValue)
        buffer.writeInteger(self.cachingStatus ? UInt8(1) : UInt8(0))
        buffer.writeInteger(self.cachingStatus ? UInt8(1) : UInt8(0))

        return buffer
    }
}