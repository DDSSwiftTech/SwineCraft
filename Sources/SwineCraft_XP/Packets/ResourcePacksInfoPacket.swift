import Foundation
import NIOCore

struct ResourcePacksInfoPacket: MCPEPacket {
    var packetType: MCPEPacketType = .RESOURCE_PACKS_INFO

    let forcedToAccept: Bool = false
    let hasAddons: Bool = false
    let scriptingEnabled: Bool = false
    let forceDisableVibrantVisuals: Bool = false
    let worldTemplateID: UUID = UUID()
    let worldTemplateVersion: String = "1.1.1"
    let resourcePackInfos: [UInt8] = []
}