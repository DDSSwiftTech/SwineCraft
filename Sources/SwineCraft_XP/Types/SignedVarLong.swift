import NIOCore

struct SignedVarLong: ExpressibleByIntegerLiteral {
    typealias IntegerLiteralType = Int64

    var backingInt: Int64 = 0

    init(integerLiteral value: IntegerLiteralType) {
        self.backingInt = value
    }

    init(buffer: inout ByteBuffer) {
        var result: Int64 = 0
        var idx: Int64 = 0

        while let currentByte: UInt8 = buffer.readInteger() {
            result |= Int64(currentByte & 0b01111111) << (7 * idx)

            if (currentByte >> 7) == 0 || idx == 9 {
                break
            }

            idx += 1
        }

        self.backingInt = result
    }

    func encode() -> ByteBuffer {
        guard self.backingInt != 0 else {
            return ByteBuffer(integer: UInt8(0))
        }

        var buffer = ByteBuffer()

        // Split backing int into groups of 7 bits

        // This looks stupid, because it is
        // The swift compiler is bad, and it can't handle this all in one go
        // Had to split it in two
        // Hopefully the optimizer can figure out what I mean

        var intPieces = [
            UInt8(backingInt & 0x7F),
            UInt8(backingInt >> 7 & 0x7F),
            UInt8(backingInt >> 14 & 0x7F),
            UInt8(backingInt >> 21 & 0x7F),
            UInt8(backingInt >> 28 & 0x0F)]
        
        intPieces += [
            UInt8(backingInt >> 35 & 0x7F),
            UInt8(backingInt >> 42 & 0x7F),
            UInt8(backingInt >> 49 & 0x7F),
            UInt8(backingInt >> 56 & 0x7F),
            UInt8(backingInt >> 63 & 0x0F)
        ]

        while intPieces.last == 0 {
            intPieces.removeLast() // remove leading zeroes
        }

        for idx in 0..<intPieces.count {
            buffer.writeInteger(intPieces[idx] | (idx < intPieces.count - 1 ? 0x80 : 0))
        }

        return buffer
    }
}

extension ByteBuffer {
    mutating func readVarLong() -> SignedVarLong {
        return SignedVarLong(buffer: &self)
    }
}