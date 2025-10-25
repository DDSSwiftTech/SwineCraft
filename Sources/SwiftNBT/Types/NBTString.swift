import NIOCore

public struct NBTString: NBTEncodable, ExpressibleByStringLiteral {
    public typealias ValueType = String

    public let tagType: NBTTagType = .STRING

    public var name: String = ""
    public var value: ValueType

    public init(stringLiteral value: StringLiteralType) {
        self.value = value
    }

    public init(name: String = "", value: ValueType) {
        self.name = name
        self.value = value
    }

    public init(body buf: inout NIOCore.ByteBuffer, endianness: Endianness) throws {
        guard let stringLength: UInt16 = buf.readInteger(endianness: endianness),
        let decodedString = buf.readString(length: Int(stringLength)) else {
            throw NBTError.BUFFER_DECODE(reason: .STRING)
        }

        self.name = ""
        self.value = decodedString
    }

    public func encodeBody(_ buf: inout NIOCore.ByteBuffer) {
        buf.writeInteger(UInt16(self.value.utf8.count), endianness: .little)
        buf.writeString(self.value)
    }

}