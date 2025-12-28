import NIOCore

public struct UnsignedVarInt: ExpressibleByIntegerLiteral, MCPEPacketEncodable {
    public typealias IntegerLiteralType = UInt32

    var backingInt: UInt32 = 0

    public init(integerLiteral value: IntegerLiteralType) {
        self.backingInt = value
    }

    public init(buffer: inout ByteBuffer) {
        var result: UInt32 = 0
        var idx: UInt32 = 0

        while let currentByte: UInt8 = buffer.readInteger() {
            result |= UInt32(currentByte & 0b01111111) << (7 * idx)

            if (currentByte >> 7) == 0 || idx == 4 {
                break
            }

            idx += 1
        }

        self.backingInt = result
    }

    func encode(_ buf: inout NIOCore.ByteBuffer) throws {
        guard self.backingInt != 0 else {
            buf.writeInteger(UInt8(self.backingInt))

            return
        }
        
        // Split backing int into groups of 7 bits

        var intPieces = [
            UInt8(backingInt & 0x7F),
            UInt8(backingInt >> 7 & 0x7F),
            UInt8(backingInt >> 14 & 0x7F),
            UInt8(backingInt >> 21 & 0x7F),
            UInt8(backingInt >> 28 & 0x0F)
        ]

        while intPieces.last == 0 {
            intPieces.removeLast() // remove leading zeroes
        }

        for idx in 0..<intPieces.count {
            buf.writeInteger(intPieces[idx] | (idx < intPieces.count - 1 ? 0x80 : 0))
        }
    }
}

extension ByteBuffer {
    public mutating func readUnsignedVarInt() -> UnsignedVarInt {
        return UnsignedVarInt(buffer: &self)
    }
}