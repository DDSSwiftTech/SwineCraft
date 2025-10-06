struct DisconnectPacket: RakNetPacket {
    var packetType: RakNetPacketType = .CLIENT_DISCONNECT
}