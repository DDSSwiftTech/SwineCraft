import NIOCore
import Foundation

enum ResourcePackStatus: UInt8 {
    case REFUSED = 1
    case SEND_PACKS = 2
    case HAVE_ALL_PACKS = 3
    case COMPLETED = 4
}

struct ResourcePackClientResponsePacket: MCPEPacket {
    var packetType: MCPEPacketType = .RESOURCE_PACK_CLIENT_RESPONSE

    let status: ResourcePackStatus
    var packIDs: [UUID] = []

    init(from buffer: inout ByteBuffer) throws {
        self.status = .init(rawValue: buffer.readInteger()!) ?? .REFUSED

        for _ in 0..<(buffer.readInteger()! as UInt16) {
            self.packIDs.append(UUID(uuidString: buffer.readString(length: buffer.readInteger() ?? 0) ?? "") ?? UUID())
        }
    }
}