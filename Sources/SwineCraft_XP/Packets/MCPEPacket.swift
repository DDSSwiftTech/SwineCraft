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
            try self.encodeValue(param.value, buffer: &buf)
        }
    }

    func encodeValue(_ value: Any, buffer buf: inout ByteBuffer) throws {
        if let value = value as? PlayStatusPacket.MCPEStatus {
            buf.writeInteger(value.rawValue)
        } else if let value = value as? CompressionMethod {
            buf.writeInteger(value.rawValue)
        } else if let value = value as? Bool {
            buf.writeInteger(UInt8(value ? 1 : 0))
        } else if let value = value as? UInt8 {
            buf.writeInteger(value)
        } else if let value = value as? UInt16 {
            buf.writeInteger(value)
        } else if let value = value as? UInt32 {
            buf.writeInteger(value)
        } else if let value = value as? UInt64 {
            buf.writeInteger(value)
        } else if let value = value as? UInt128 {
            buf.writeInteger(value)
        } else if let value = value as? Int8 {
            buf.writeInteger(value)
        } else if let value = value as? Int16 {
            buf.writeInteger(value)
        } else if let value = value as? Int32 {
            buf.writeInteger(value)
        } else if let value = value as? Int64 {
            buf.writeInteger(value)
        } else if let value = value as? Int128 {
            buf.writeInteger(value)
        } else if let value = value as? Float {
            buf.writeInteger(value.bitPattern)
        } else if let value = value as? UUID {
            let _ = withUnsafeBytes(of: value.uuid) { ptr in
                buf.writeBytes(ptr)
            }
        } else if let value = value as? [any FixedWidthInteger] {
            buf.writeInteger(UInt16(value.count), endianness: .little)
            for item in value {
                try self.encodeValue(item, buffer: &buf)
            }
        } else if let value = value as? String {
            try UnsignedVarInt(integerLiteral: UInt32(value.utf8.count)).encode(&buf)
            buf.writeString(value)
        }
    }
}