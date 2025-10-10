import NIOCore
import Foundation

struct StartGamePacket: MCPEPacket {
    var packetType: MCPEPacketType = .START_GAME

    let playerEntityID: VarLong
    let runtimeEntityID: UnsignedVarLong
    let playerGamemode: UnsignedVarInt
    let spawn: (Float, Float, Float)
    let rotation: (Float, Float)
    let seed: UnsignedVarInt
    let spawnBiomeType: MCPEShort
    let customBiomeName: String
    let dimension: UnsignedVarInt
    let generator: UnsignedVarInt
    let worldGamemode: UnsignedVarInt
    let difficulty: UnsignedVarInt
    let worldSpawn: (VarInt, UnsignedVarInt, VarInt) // x, y, z
    let hasAchievementsEnabled: Bool
    let dayCycleStopTime: VarInt
    let eduOffer: VarInt
    let hasEducationEditionFeaturesEnabled: Bool
    let educationProductionID: String
    let rainLevel: Float
    let lightingLevel: Float
    let hasConfirmedPlatformLockedContent: Bool
    let isMultiplayer: Bool
    let broadcastToLAN: Bool
    let xboxLiveBroadcastMode: UnsignedVarInt
    let platformBroadcastMode: UnsignedVarInt
    let enableCommands: Bool
    let texturePacksRequired: Bool
    let gameRules: Data // TODO, what is a game rule?
    let bonusChest: Bool
    let mapEnabled: Bool
    let permissionLevel: VarInt
    let serverChunkTickRange: Int
    let hasLockedBehaviorPack: Bool
    let hasLockedResourcePack: Bool
    let isFromLockedWorldTemplate: Bool
    let useMSAGamertagsOnly: Bool
    let isFromWorldTemplate: Bool
    let isWorldTemplateOptionLocked: Bool
    let onlySpawnV1Villagers: Bool
    let gameVersion: String // Vanilla game version
    let limitedWorldWidth: Int
    let limitedWorldHeight: Int
    let isNetherType: Bool
    let isForceExperimentalGameplay: Bool
    let levelID: String
    let worldName: String
    let premiumWorldTemplateID: String
    let isTrial: Bool
    let movementType: UnsignedVarInt
    let movementRewindSize: Int
    let serverAuthoritativeBlockBreaking: Bool
    let currentTick: MCPELong // Little endian
    let enchantmentSeed: VarInt
    let blockProperties: [String] // TODO
    let itemStates: [String] // TODO
    let multiplayerCorrelationID: String
    let inventoriesServerAuthoritative: Bool

    // init(from buffer: inout ByteBuffer) throws {
    //     self.seed = .init(integerLiteral: buffer.readInteger()!)
    // }
}