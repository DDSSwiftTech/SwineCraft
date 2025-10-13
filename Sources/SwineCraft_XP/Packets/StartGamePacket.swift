import NIOCore
import Foundation

struct StartGamePacket: MCPEPacket {
    var packetType: MCPEPacketType = .START_GAME

    let playerEntityID: VarLong
    let runtimeEntityID: UnsignedVarLong
    let playerGamemode: VarInt
    let position: Vec3
    let rotation: Vec2
    let settings: LevelSettings
    let levelID: String
    let levelName: String
    let templateContentIdentity: String
    let isTrial: Bool
    let movementSettings: SyncedPlayerMovementSettings
    let levelCurrentTime: UInt64
    let enchantmentSeed: VarInt
    let blockProperties: [BlockProperty]
}