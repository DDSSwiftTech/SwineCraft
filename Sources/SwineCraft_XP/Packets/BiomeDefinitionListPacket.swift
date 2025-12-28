struct BiomeDefinitionListPacket: MCPEPacket {
    var packetType: MCPEPacketType = .BIOME_DEFINITION_LIST

    let biomeDefinitionList: [Any] = []
    let strings: [String] = []
}