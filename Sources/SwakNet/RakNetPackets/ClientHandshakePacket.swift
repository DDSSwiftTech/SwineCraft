import NIOCore

struct ClientHandshakePacket: RakNet.Packet {
    var packetType: RakNet.PacketType = .CLIENT_HANDSHAKE

    let serverAddress: RakNet.Address
    let clientAddresses: [RakNet.Address] // MCPE uses 20 of them
    let incomingTimestamp: Int64
    let serverTimestamp: Int64

    init(from buffer: inout ByteBuffer) throws {
        self.serverAddress = buffer.readAddress()

        self.clientAddresses = [RakNet.Address].init(unsafeUninitializedCapacity: 20) { arrayBuffer, initializedCount in
            for i in 0..<20 {
                (arrayBuffer.baseAddress! + i).pointee = buffer.readAddress()
            }

            initializedCount = 20
        }

        self.incomingTimestamp = buffer.readInteger()!
        self.serverTimestamp = buffer.readInteger()!
    }
}