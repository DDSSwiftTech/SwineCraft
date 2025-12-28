import NIO
import Foundation

protocol MCPEPacket: MCPEPacketCodable {
    var packetType: MCPEPacketType { get }
}

extension MCPEPacket {
    init(from buffer: inout ByteBuffer) throws {
        throw MCPEError.PacketDecode(nil)
    }
}