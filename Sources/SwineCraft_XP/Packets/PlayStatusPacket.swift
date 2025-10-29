import NIOCore

struct PlayStatusPacket: MCPEPacket {
    var packetType: MCPEPacketType = .PLAY_STATUS

    enum MCPEStatus: Int32 {
        case LOGIN_SUCCESS
        case FAILED_CLIENT
        case FAILED_SERVER
        case PLAYER_SPAWN
        case FAILED_INVALID_TENANT
        case FAILED_VANILLA_EDU
        case FAILED_INCOMPATIBLE
        case FAILED_SERVER_FULL
    }

    let status: MCPEStatus

    init(status: MCPEStatus) {
        self.status = status
    }
}