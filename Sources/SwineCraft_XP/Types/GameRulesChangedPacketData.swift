public struct GamesRulesChangedPacketData: MCPEPacketEncodable {
    public let rulesList: [GameRule]
}