import NIOCore

struct ClientCacheStatusPacket: MCPEPacket {
    var packetType: MCPEPacketType = .CLIENT_CACHE_STATUS

    let cachingStatus: Bool
    let cachingStatus2: Bool

    init(from buffer: inout ByteBuffer) throws {
        self.cachingStatus = buffer.readBytes(length: 1)?.first == 1
        self.cachingStatus2 = cachingStatus
    }
}