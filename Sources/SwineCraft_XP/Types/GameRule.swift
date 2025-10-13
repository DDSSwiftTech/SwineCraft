struct GameRule {
    let ruleName: String
    let canBeModifiedByPlayer: Bool
    let ruleType: (VarInt, VarInt, VarInt)
    let ruleValue: Bool
}