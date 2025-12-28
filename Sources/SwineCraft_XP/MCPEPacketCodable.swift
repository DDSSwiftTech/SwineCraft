import NIOCore
import Foundation

protocol MCPEPacketEncodable {
    func encode(_ buf: inout ByteBuffer) throws
    func encodeValue(_ value: Any, buffer buf: inout ByteBuffer) throws
}

protocol MCPEPacketDecodable {
    init(from buffer: inout ByteBuffer) throws
}

typealias MCPEPacketCodable = MCPEPacketEncodable & MCPEPacketDecodable

extension MCPEPacketEncodable {
    func encode(_ buf: inout ByteBuffer) throws {
        for param in Mirror(reflecting: self).children {
            try self.encodeValue(param.value, buffer: &buf)
        }
    }

    // The point of this is to give me the ability to create data structures
    // without having to write this for every type the struct may have
    // This will encode all potential values
    func encodeValue(_ value: Any, buffer buf: inout ByteBuffer) throws {
        if let value = value as? Bool {
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
        } else if let value = value as? VarInt {
            try value.encode(&buf)
        } else if let value = value as? UnsignedVarInt {
            try value.encode(&buf)
        } else if let value = value as? VarLong {
            try value.encode(&buf)
        } else if let value = value as? UnsignedVarLong {
            try value.encode(&buf)
        } else if let value = value as? UUID {
            let _ = withUnsafeBytes(of: value.uuid) { ptr in
                buf.writeBytes(ptr)
            }
        } else if let value = value as? String {
            try UnsignedVarInt(integerLiteral: UInt32(value.utf8.count)).encode(&buf)
            buf.writeString(value)
        } else if let value = value as? [any MCPEPacketEncodable] {
            try UnsignedVarInt(integerLiteral: UInt32(value.count)).encode(&buf)
            for item in value {
                try self.encodeValue(item, buffer: &buf)
            }
        } else if let value = value as? any RawRepresentable {
            try self.encodeValue(value.rawValue, buffer: &buf)
        } else if let value = value as? any MCPEPacketEncodable {
            try value.encode(&buf)
        }
    }
}