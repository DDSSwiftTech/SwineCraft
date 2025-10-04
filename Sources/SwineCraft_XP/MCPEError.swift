extension MCPE {
    enum Error: Swift.Error {
        case PacketDecode(MCPEPacketType?)
        case UnknownPacketType
    }
}