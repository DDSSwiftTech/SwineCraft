import SwiftNBT

public struct LevelSettings {
    public let seed: UInt64
    public let spawnSettings: SpawnSettings
    public let generatorType: UnsignedVarInt
    public let gameType: VarInt
    public let hardcoreModeEnabled: Bool
    public let gameDifficulty: VarInt
    public let defaultSpawnBlockPosition: NetworkBlockPosition
    public let achievementsDisabled: Bool
    public let editorWorldType: VarInt
    public let createdInEditor: Bool
    public let exportedFromEditor: Bool
    public let dayCycleStopTime: VarInt
    public let educationEditionOffer: VarInt
    public let educationFeaturesEnabled: Bool
    public let educationProductId: String
    public let rainLevel: Float
    public let lightingLevel: Float
    public let confirmedPlatformLockedContent: Bool
    public let multiplayerIntendedToBeEnabled: Bool
    public let LANBroadcastingIntendedToBeEnabled: Bool
    public let xboxLiveBroadcastingSetting: VarInt
    public let platformBroadcastSetting: VarInt
    public let commandsEnabled: Bool
    public let texturePacksRequired: Bool
    public let ruleData: GamesRulesChangedPacketData
    public let experiments: Experiments
    public let bonusChestEnabled: Bool
    public let startWithMapEnabled: Bool
    public let playerPermissions: VarInt
    public let serverChunkTickRange: Int32
    public let hasLockedBehaviorPack: Bool
    public let hasLockedResourcePack: Bool
    public let isFromLockedTemplate: Bool
    public let useMSAGamertagsOnly: Bool
    public let createdFromTemplate: Bool = false
    public let islockedTemplate: Bool = false
    public let onlySpawnV1Villagers: Bool
    public let personaDisabled: Bool
    public let customSkinsDisabled: Bool
    public let emoteChatMuted: Bool
    public let baseGameVersion: String
    public let limitedWorldWidth: Int32
    public let limitedWorldDepth: Int32
    public let netherType: Bool
    public let eduSharedURIResource: EduSharedURIResource
    public let overrideForceExperimentalGameplayHasValue: Bool = false
    public let chatRestrictionLevel: UInt8
    public let disablePlayerInteractions: Bool
    public let serverIdentifier: String
    public let worldIdentifier: String
    public let scenarioIdentifier: String
    public let ownerIdentifier: String

    public init(_ compound: NBTCompound) {
        self.seed = UInt64((compound["RandomSeed"] as! NBTLong).value)
        self.spawnSettings = SpawnSettings(
            type: 0,
            userDefinedBiomeName: (compound["BiomeOverride"] as! NBTString).value,
            dimension: 0
        )
        self.generatorType = UnsignedVarInt(integerLiteral: UInt32((compound["Generator"] as! NBTInt).value))
        self.gameType = VarInt(integerLiteral: (Int32((compound["GameType"] as! NBTInt).value)))
        self.hardcoreModeEnabled = (compound["IsHardcore"] as! NBTByte) == 1
        self.gameDifficulty = VarInt(integerLiteral: (compound["Difficulty"] as! NBTInt).value)
        self.defaultSpawnBlockPosition = NetworkBlockPosition(
            x: VarInt(integerLiteral: (compound["SpawnX"] as! NBTInt).value),
            y: UnsignedVarInt(integerLiteral: UInt32((compound["SpawnY"] as! NBTInt).value)),
            z: VarInt(integerLiteral: (compound["SpawnZ"] as! NBTInt).value)
        )
        self.achievementsDisabled = true
        self.editorWorldType = VarInt(integerLiteral: (compound["editorWorldType"] as! NBTInt).value)
        self.createdInEditor = (compound["isCreatedInEditor"] as! NBTByte) == 1
        self.exportedFromEditor = (compound["isExportedFromEditor"] as! NBTByte) == 1
        self.dayCycleStopTime = 0
        self.educationEditionOffer = VarInt(integerLiteral: (compound["eduOffer"] as! NBTInt).value)
        self.educationFeaturesEnabled = (compound["educationFeaturesEnabled"] as! NBTByte) == 1
        self.educationProductId = (compound["prid"] as! NBTString).value
        self.rainLevel = (compound["rainLevel"] as! NBTFloat).value
        self.lightingLevel = (compound["lightningLevel"] as! NBTFloat).value
        self.confirmedPlatformLockedContent = (compound["ConfirmedPlatformLockedContent"] as! NBTByte) == 1
        self.multiplayerIntendedToBeEnabled = (compound["MultiplayerGameIntent"] as! NBTByte) == 1
        self.LANBroadcastingIntendedToBeEnabled = (compound["LANBroadcastIntent"] as! NBTByte) == 1
        self.xboxLiveBroadcastingSetting = VarInt(integerLiteral: (compound["XBLBroadcastIntent"] as! NBTInt).value)
        self.platformBroadcastSetting = VarInt(integerLiteral: (compound["PlatformBroadcastIntent"] as! NBTInt).value)
        self.commandsEnabled = (compound["commandsEnabled"] as! NBTByte) == 1
        self.texturePacksRequired = false
        self.ruleData = GamesRulesChangedPacketData(rulesList: [])

        let experiments = compound["experiments"] as! NBTCompound

        self.experiments = Experiments(experimentList: experiments.value.filter {$0.name != "saved_with_toggled_experiments"}.map {
            Experiments.Experiment(name: $0.name, enabled: ($0 as! NBTByte) == 1)
        }, wereAnyExperimentsEverToggled: (experiments["saved_with_toggled_experiments"] as! NBTByte) == 1)
        self.bonusChestEnabled = (compound["bonusChestEnabled"] as! NBTByte) == 1
        self.startWithMapEnabled = (compound["startWithMapEnabled"] as! NBTByte) == 1
        self.playerPermissions = VarInt(integerLiteral: (compound["playerPermissionsLevel"] as! NBTInt).value)
        self.serverChunkTickRange = (compound["serverChunkTickRange"] as! NBTInt).value
        self.hasLockedBehaviorPack = (compound["hasLockedBehaviorPack"] as! NBTByte) == 1
        self.hasLockedResourcePack = (compound["hasLockedResourcePack"] as! NBTByte) == 1
        self.isFromLockedTemplate = (compound["isFromLockedTemplate"] as! NBTByte) == 1
        self.useMSAGamertagsOnly = (compound["useMsaGamertagsOnly"] as! NBTByte) == 1
        self.onlySpawnV1Villagers = (compound["SpawnV1Villagers"] as! NBTByte) == 1
        self.personaDisabled = true
        self.customSkinsDisabled = true
        self.emoteChatMuted = true
        self.baseGameVersion = (compound["MinimumCompatibleClientVersion"] as! NBTList).value.map {String(($0 as! NBTInt).value)}.joined(separator: ".")
        self.limitedWorldDepth = (compound["limitedWorldDepth"] as! NBTInt).value
        self.limitedWorldWidth = (compound["limitedWorldWidth"] as! NBTInt).value
        self.netherType = false
        self.eduSharedURIResource = EduSharedURIResource(buttonName: "Google", linkURI: "https://www.google.com/")
        self.chatRestrictionLevel = 0
        self.disablePlayerInteractions = false
        self.serverIdentifier = "SwiftMCPEServer"
        self.worldIdentifier = "Default World"
        self.scenarioIdentifier = "Default Scenario"
        self.ownerIdentifier = "Default Owner"
    }
}