struct ItemStack: MCPEPacketEncodable {
    let id: VarInt
    let count: UInt16
    let meta: UnsignedVarInt
    let blockRuntimeId: VarInt
    let rawExtraData: String
}