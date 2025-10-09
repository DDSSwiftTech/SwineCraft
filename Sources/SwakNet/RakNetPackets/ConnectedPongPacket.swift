import NIOCore

struct ConnectedPongPacket: RakNetPacket {
    let packetType: RakNetPacketType = .CONNECTED_PONG
    let clientTime: Int64
    let serverTime: Int64

    init(clientTime: Int64, serverTime: Int64) {
        self.clientTime = clientTime
        self.serverTime = serverTime
    }

    init(from buffer: inout ByteBuffer) throws {
        self.clientTime = buffer.readInteger() ?? 0
        self.serverTime = buffer.readInteger() ?? 0
    }
}