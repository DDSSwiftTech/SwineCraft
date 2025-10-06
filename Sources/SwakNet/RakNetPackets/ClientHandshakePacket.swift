import NIOCore

struct ClientHandshakePacket: RakNetPacket {
    var packetType: RakNetPacketType = .CLIENT_HANDSHAKE

    let serverAddress: RakNetAddress
    let clientAddresses: [RakNetAddress] // MCPE uses 20 of them
    let incomingTimestamp: Int64
    let serverTimestamp: Int64

    init(from buffer: inout ByteBuffer) throws {
        self.serverAddress = buffer.readAddress()

        self.clientAddresses = [RakNetAddress].init(unsafeUninitializedCapacity: 20) { arrayBuffer, initializedCount in
            for i in 0..<20 {
                (arrayBuffer.baseAddress! + i).pointee = buffer.readAddress()
            }

            initializedCount = 20
        }

        self.incomingTimestamp = buffer.readInteger()!
        self.serverTimestamp = buffer.readInteger()!
    }
}