import NIO
import Foundation

protocol MCPEPacket: MCPEPacketCodable {
    var packetType: MCPEPacketType { get }
}

extension MCPEPacket {
    init(from buffer: inout ByteBuffer) throws {
        throw MCPEError.PacketDecode(nil)
    }

    func encode(_ buf: inout ByteBuffer) throws {
        buf.writeInteger(self.packetType.rawValue)

        for param in Mirror(reflecting: self).children {
            if let value = param.value as? PlayStatusPacket.MCPEStatus {
                buf.writeInteger(value.rawValue)
            } else if let value = param.value as? CompressionMethod {
                buf.writeInteger(value.rawValue)
            } else if let value = param.value as? Bool {
                buf.writeInteger(UInt8(value ? 1 : 0))
            } else if let value = param.value as? UInt8 {
                buf.writeInteger(value)
            } else if let value = param.value as? UInt16 {
                buf.writeInteger(value)
            } else if let value = param.value as? UInt32 {
                buf.writeInteger(value)
            } else if let value = param.value as? UInt64 {
                buf.writeInteger(value)
            } else if let value = param.value as? UInt128 {
                buf.writeInteger(value)
            } else if let value = param.value as? Int8 {
                buf.writeInteger(value)
            } else if let value = param.value as? Int16 {
                buf.writeInteger(value)
            } else if let value = param.value as? Int32 {
                buf.writeInteger(value)
            } else if let value = param.value as? Int64 {
                buf.writeInteger(value)
            } else if let value = param.value as? Int128 {
                buf.writeInteger(value)
            } else if let value = param.value as? Float {
                buf.writeInteger(value.bitPattern)
            } else if let value = param.value as? UUID {
                withUnsafeBytes(of: value.uuid) { ptr in
                    let uuidInt = ptr.assumingMemoryBound(to: UInt128.self)

                    buf.writeInteger(uuidInt.baseAddress!.pointee)
                }
            } else if let value = param.value as? [UInt8] {
                buf.writeInteger(UInt16(value.count), endianness: .little)
                buf.writeBytes(value)
            } else if let value = param.value as? String {
                try UnsignedVarInt(integerLiteral: UInt32(value.utf8.count)).encode(&buf)
                buf.writeString(value)
            }
        }
    }
}