struct DisconnectPacket: RakNet.Packet {
    var packetType: RakNet.PacketType = .CLIENT_DISCONNECT
}