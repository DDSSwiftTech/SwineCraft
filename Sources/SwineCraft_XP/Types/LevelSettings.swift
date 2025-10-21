import SwiftNBT

struct LevelSettings {
    let seed: UInt64
    let spawnSettings: SpawnSettings
    let generatorType: UnsignedVarInt
    let gameType: VarInt
    let hardcoreModeEnabled: Bool
    let gameDifficulty: VarInt
    let defaultSpawnBlockPosition: NetworkBlockPosition
    let achievementsDisabled: Bool
    let editorWorldType: VarInt
    let createdInEditor: Bool
    let exportedFromEditor: Bool
    let dayCycleStopTime: VarInt
    let educationEditionOffer: VarInt
    let educationFeaturesEnabled: Bool
    let educationProductId: String
    let rainLevel: Float
    let lightingLevel: Float
    let confirmedPlatformLockedContent: Bool
    let multiplayerIntendedToBeEnabled: Bool
    let LANBroadcastingIntendedToBeEnabled: Bool
    let xboxLiveBroadcastingSetting: VarInt
    let platformBroadcastSetting: VarInt
    let commandsEnabled: Bool
    let texturePacksRequired: Bool
    let ruleData: GamesRulesChangedPacketData
    let experiments: Experiments
    let bonusChestEnabled: Bool
    let startWithMapEnabled: Bool
    let playerPermissions: VarInt
    let serverChunkTickRange: Int
    let hasLockedBehaviorPack: Bool
    let hasLockedResourcePack: Bool
    let isFromLockedTemplate: Bool
    let useMSAGamertagsOnly: Bool
    let createdFromTemplate: Bool = false
    let islockedTemplate: Bool = false
    let onlySpawnV1Villagers: Bool
    let personaDisabled: Bool
    let customSkinsDisabled: Bool
    let emoteChatMuted: Bool
    let baseGameVersion: String
    let limitedWorldWidth: Int
    let limitedWorldDepth: Int
    let netherType: Bool
    let eduSharedURIResource: EduSharedURIResource
    let overrideForceExperimentalGameplayHasValue: Bool = false
    let chatRestrictionLevel: UInt8
    let disablePlayerInteractions: Bool
    let serverIdentifier: String
    let worldIdentifier: String
    let scenarioIdentifier: String
    let ownerIdentifier: String

    private init(_ compound: NBTCompound) {
        self.seed = UInt64((compound.value.first {$0.name == "RandomSeed"} as! NBTLong).value)
        self.spawnSettings = SpawnSettings(
            type: 0,
            userDefinedBiomeName: (compound.value.first {$0.name == "BiomeOverride"} as! NBTString).value,
            dimension: 0
        )
        self.generatorType = UnsignedVarInt(integerLiteral: UnsignedVarInt.IntegerLiteralType((compound.value.first {$0.name == "Generator"} as! NBTInt).value))
        self.gameType = VarInt(integerLiteral: (compound.value.first {$0.name == "GameType"} as! NBTInt).value)
        self.hardcoreModeEnabled = (compound.value.first {$0.name == "IsHardcore"} as! NBTByte).value == 1
        self.gameDifficulty = VarInt(integerLiteral: (compound.value.first {$0.name == "Difficulty"} as! NBTInt).value)
        self.defaultSpawnBlockPosition = NetworkBlockPosition(
            x: VarInt(integerLiteral: (compound.value.first {$0.name == "SpawnX"} as! NBTInt).value),
            y: UnsignedVarInt(integerLiteral: UInt32((compound.value.first {$0.name == "SpawnY"} as! NBTInt).value)),
            z: VarInt(integerLiteral: (compound.value.first {$0.name == "SpawnZ"} as! NBTInt).value)
        )
        self.achievementsDisabled = true
        self.editorWorldType = VarInt(integerLiteral: (compound.value.first {$0.name == "editorWorldType"} as! NBTInt).value)
        self.createdInEditor = (compound.value.first {$0.name == "isCreatedInEditor"} as! NBTByte).value == 1
        self.exportedFromEditor = (compound.value.first {$0.name == "isExportedFromEditor"} as! NBTByte).value == 1
        self.dayCycleStopTime = 0
        self.educationEditionOffer = VarInt(integerLiteral: (compound.value.first {$0.name == "eduOffer"} as! NBTInt).value)
        self.educationFeaturesEnabled = (compound.value.first {$0.name == "educationFeaturesEnabled"} as! NBTByte).value == 1
        self.educationProductId = (compound.value.first {$0.name == "prid"} as! NBTString).value
        self.rainLevel = (compound.value.first {$0.name == "rainLevel"} as! NBTFloat).value
        self.lightingLevel = (compound.value.first {$0.name == "lightningLevel"} as! NBTFloat).value
        self.confirmedPlatformLockedContent = (compound.value.first {$0.name == "ConfirmedPlatformLockedContent"} as! NBTByte).value == 1
        self.multiplayerIntendedToBeEnabled = (compound.value.first {$0.name == "MultiplayerGameIntent"} as! NBTByte).value == 1
        self.LANBroadcastingIntendedToBeEnabled = (compound.value.first {$0.name == "LANBroadcastIntent"} as! NBTByte).value == 1
        self.xboxLiveBroadcastingSetting = VarInt(integerLiteral: (compound.value.first {$0.name == "XBLBroadcastIntent"} as! NBTInt).value)
    }
}