public struct SpawnSettings: MCPEPacketEncodable {
    public let type: MCPEShort
    public let userDefinedBiomeName: String
    public let dimension: VarInt
}