public struct GameRule {
    public let ruleName: String
    public let canBeModifiedByPlayer: Bool
    public let ruleType: (VarInt, VarInt, VarInt)
    public let ruleValue: Bool
}