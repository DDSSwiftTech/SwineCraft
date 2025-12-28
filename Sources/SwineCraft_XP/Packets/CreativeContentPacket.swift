import NIOCore

struct CreativeContentPacket: MCPEPacket {
    enum ContentCategory: UInt8 {
        case CONSTRUCTION = 1
        case NATURE = 2
        case EQUIPMENT = 3
        case ITEMS = 4
    }
    var packetType: MCPEPacketType = .CREATIVE_CONTENT

    // var groups: [CreativeGroupEntry] = [CreativeGroupEntry(
    //     categoryId: 1, categoryName: "Construction", icon: ItemStack(id: 5, count: 0, meta: 5, blockRuntimeId: 5, rawExtraData: ""))]
    // var items: [CreativeItemEntry] = [
    //     CreativeItemEntry(
    //         entryId: 50,
    //         item: ItemStack(
    //             id: 5,
    //             count: 0,
    //             meta: 5,
    //             blockRuntimeId: 5,
    //             rawExtraData: ""),
    //         groupId: 0
    //     )
    // ]
}