extension RakNet {
    enum PacketType: UInt8 {
        case CONNECTED_PING = 0x00
        case UNCONNECTED_PING_0 = 0x01
        case UNCONNECTED_PING_1 = 0x02
        case CONNECTED_PONG = 0x03
        case OFFLINE_CONNECTION_REQUEST_1 = 0x05
        case OFFLINE_CONNECTION_RESPONSE_1 = 0x06
        case OFFLINE_CONNECTION_REQUEST_2 = 0x07
        case OFFLINE_CONNECTION_RESPONSE_2 = 0x08
        case ONLINE_CONNECTION_REQUEST = 0x09
        case ONLINE_CONNECTION_REQUEST_ACCEPTED = 0x10
        case CLIENT_HANDSHAKE = 0x13
        case CLIENT_DISCONNECT = 0x15
        case INCOMPATIBLE_PROTOCOL = 0x19
        case UNCONNECTED_PONG = 0x1C
        case ADVERTISE_SYSTEM = 0x1D
        case DATA_PACKET_0 = 0x80
        case DATA_PACKET_1
        case DATA_PACKET_2
        case DATA_PACKET_3
        case DATA_PACKET_4
        case DATA_PACKET_5
        case DATA_PACKET_6
        case DATA_PACKET_7
        case DATA_PACKET_8
        case DATA_PACKET_9
        case DATA_PACKET_A
        case DATA_PACKET_B
        case DATA_PACKET_C
        case DATA_PACKET_D
        case DATA_PACKET_E
        case DATA_PACKET_F
        case NACK = 0xA0
        case ACK = 0xC0
        case GAME_PACKET = 0xFE
    }
}