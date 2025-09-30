import NIOCore

struct ConnectedPingPacket: RakNet.Packet {
    let packetType: RakNet.PacketType = .CONNECTED_PING
    let time: Int64

    init(from buffer: inout ByteBuffer) throws {
        self.time = buffer.readInteger() ?? 0
    }
}