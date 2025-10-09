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
            switch type(of: child.value) {
                case is UInt16.Type:
                    buffer.writeInteger(child.value as! UInt16)
                case is UInt32.Type:
                    buffer.writeInteger(child.value as! UInt32)
                case is UInt64.Type:
                    buffer.writeInteger(child.value as! UInt64)
                case is UInt128.Type:
                    buffer.writeInteger(child.value as! UInt128)
                case is String.Type:
                    buffer.writeInteger(UInt16((child.value as! String).count))
                    buffer.writeBytes((child.value as! String).map {$0.asciiValue!})
                case is Bool.Type:
                    buffer.writeBytes([child.value as! Bool ? 1 : 0])
                case is RakNetAddress.Type:
                    var addrBuf = (child.value as! RakNetAddress).encode()
                    buffer.writeBuffer(&addrBuf)
                default:
                    break
            }
        }
        
        return buffer
    }
}