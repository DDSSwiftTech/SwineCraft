
    enum RakNetError: Swift.Error {
        case PacketDecode(RakNetPacketType)
        case Decapsulation(RakNetDecapsulationFailure)
        case UnknownPacketType
    }