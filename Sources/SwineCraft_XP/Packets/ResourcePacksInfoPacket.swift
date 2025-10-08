struct ResourcePacksInfoPacket: MCPEPacket {
    var packetType: MCPEPacketType = .RESOURCE_PACKS_INFO

    let forcedToAccept: Bool
    let scriptingEnabled: Bool
    let behaviorPackInfos: [UInt8]
    let resourcePackInfos: [UInt8]
}