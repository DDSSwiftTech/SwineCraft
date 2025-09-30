import NIOCore

struct ConnectionRequestPacket: RakNet.Packet {
    var packetType: RakNet.PacketType = .ONLINE_CONNECTION_REQUEST

    let GUID: UInt64
    let time: UInt64
    let useSecurity: Bool

    init(from buffer: inout ByteBuffer) throws {
        guard let GUID: UInt64 = buffer.readInteger(),
        let time: UInt64 = buffer.readInteger(),
        let useSecurity: UInt8 = buffer.readInteger() else {
            throw RakNet.Error.PacketDecode(self.packetType)
        }
        
        self.GUID = GUID
        self.time = time
        self.useSecurity = useSecurity == 1
    }
}