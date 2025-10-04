import Foundation

class PlayerHandler {
    static let PLAYER_DB_PATH = "/etc"
    private var activePlayerList: [UUID: Player]

    init() {
        activePlayerList = [:]
    }


}