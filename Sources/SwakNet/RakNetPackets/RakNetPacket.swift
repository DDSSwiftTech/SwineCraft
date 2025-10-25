import NIO

protocol RakNetPacket {
    var packetType: RakNetPacketType { get }

    init(from buffer: inout ByteBuffer) throws
    func encode() throws -> ByteBuffer
}

extension RakNetPacket {
    init(from buffer: inout ByteBuffer) throws {
        throw RakNetError.PacketDecode(.INCOMPATIBLE_PROTOCOL)
    }

    func encode() throws -> ByteBuffer {
        var buffer = ByteBuffer()

        buffer.writeInteger(self.packetType.rawValue)
        
        for child in Mirror(reflecting: self).children {
            if let item = child.value as? UInt8 {
                buffer.writeInteger(item)
            } else if let item = child.value as? UInt16 {
                buffer.writeInteger(item)
            } else if let item = child.value as? UInt32 {
                buffer.writeInteger(item)
            } else if let item = child.value as? UInt64 {
                buffer.writeInteger(item)
            } else if let item = child.value as? UInt128 {
                buffer.writeInteger(item)
            } else if let item = child.value as? Int8 {
                buffer.writeInteger(item)
            } else if let item = child.value as? Int16 {
                buffer.writeInteger(item)
            } else if let item = child.value as? Int32 {
                buffer.writeInteger(item)
            } else if let item = child.value as? Int64 {
                buffer.writeInteger(item)
            } else if let item = child.value as? String {
                buffer.writeInteger(UInt16(item.count))
                buffer.writeBytes(item.map {$0.asciiValue!})
            } else if let item = child.value as? Bool {
                buffer.writeInteger(UInt8(item ? 1 : 0))
            } else if let item = child.value as? RakNetAddress {
                var addrBuf = item.encode()
                buffer.writeBuffer(&addrBuf)
            }
        }
        
        return buffer
    }
}