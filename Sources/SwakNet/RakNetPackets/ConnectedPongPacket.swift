import NIOCore

struct ConnectedPongPacket: RakNet.Packet {
    let packetType: RakNet.PacketType = .CONNECTED_PONG
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

    func encode() throws -> ByteBuffer {
        var buffer = ByteBuffer()

        buffer.writeInteger(self.packetType.rawValue)
        buffer.writeInteger(self.clientTime)
        buffer.writeInteger(self.serverTime)

        return buffer
    }
}