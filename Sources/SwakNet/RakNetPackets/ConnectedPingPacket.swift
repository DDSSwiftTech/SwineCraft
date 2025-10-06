import NIOCore

struct ConnectedPingPacket: RakNetPacket {
    let packetType: RakNetPacketType = .CONNECTED_PING
    let time: Int64

    init(from buffer: inout ByteBuffer) throws {
        self.time = buffer.readInteger() ?? 0
    }
}