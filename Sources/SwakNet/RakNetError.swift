extension RakNet {
    enum Error: Swift.Error {
        case PacketDecode(RakNet.PacketType)
        case Decapsulation(RakNet.DecapsulationFailure)
        case UnknownPacketType
    }
}