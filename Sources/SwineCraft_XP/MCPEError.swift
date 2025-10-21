enum MCPEError: Swift.Error {
    case PacketDecode(MCPEPacketType?)
    case UnknownPacketType
    case KeyPathNotFound
}