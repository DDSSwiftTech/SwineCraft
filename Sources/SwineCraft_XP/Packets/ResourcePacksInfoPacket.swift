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

    func encodeValue(_ value: Any, buffer buf: inout ByteBuffer) throws {
        if let value = value as? any RawRepresentable {
            try self.encodeValue(value.rawValue, buffer: &buf)
        } else if let value = value as? UInt8 {
            buf.writeInteger(value)
        } else if let value = value as? Bool {
            buf.writeInteger(UInt8(value ? 1 : 0))
        } else if let value = value as? UUID {
            let _ = withUnsafeBytes(of: value.uuid) { ptr in
                buf.writeBytes(ptr)
            }
        } else if let value = value as? String {
            try UnsignedVarInt(integerLiteral: UInt32(value.utf8.count)).encode(&buf)
            buf.writeString(value)
        } else if let value = value as? [Any] {
            buf.writeInteger(UInt16(value.count))
            for item in value {
                try self.encodeValue(item, buffer: &buf)
            }
        }
    }
}