struct CreativeItemEntry: MCPEPacketEncodable {
    let entryId: UnsignedVarInt
    let item: ItemStack
    let groupId: UnsignedVarInt
}