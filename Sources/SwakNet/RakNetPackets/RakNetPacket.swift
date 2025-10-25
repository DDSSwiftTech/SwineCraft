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
            } else if let item = child.value as? SequenceNumber {
                switch item {
                    case .single(_):
                        buffer.writeInteger(UInt16(1))
                    case .range(let range):
                        buffer.writeInteger(UInt16(truncatingIfNeeded: range.count))
                }
                switch item {
                    case .single(let seq):
                        buffer.writeInteger(UInt8(1)) // Is single sequence number
                        buffer.writeUInt24(seq, endianness: .little)
                    case .range(let seqRange):
                        buffer.writeInteger(UInt8(0)) // Is not single sequence number
                        buffer.writeUInt24(seqRange.lowerBound, endianness: .little)
                        buffer.writeUInt24(seqRange.upperBound, endianness: .little)
                }
            }
        }
        
        return buffer
    }
}