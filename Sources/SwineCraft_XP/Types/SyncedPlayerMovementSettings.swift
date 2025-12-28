struct SyncedPlayerMovementSettings: MCPEPacketEncodable {
    let rewindHistorySize: VarInt
    let serverAuthoritativeBlockBreaking: Bool
}