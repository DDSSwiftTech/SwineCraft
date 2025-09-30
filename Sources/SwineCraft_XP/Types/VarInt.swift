import NIOCore

extension MCPE {
    struct VarInt: ExpressibleByIntegerLiteral {
        typealias IntegerLiteralType = Int64

        private let backingInt: Int64

        init(integerLiteral value: Int64) {
            self.backingInt = value
        }

        init(buffer: inout ByteBuffer) {
            var result: Int64 = 0

            var idx: Int64 = 0

            while let currentByte: UInt8 = buffer.readInteger(){
                result |= Int64(currentByte & 0b01111111) << (7 * idx)

                if (currentByte >> 7) == 0 {
                    break
                }

                idx += 1
            }

            self.backingInt = result
        }

        func encode() -> ByteBuffer {
            
        }
    }
}