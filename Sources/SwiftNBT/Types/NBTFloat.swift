import NIOCore

public struct NBTFloat: NBTEncodable {
    public typealias ValueType = Float

    public let tagType: NBTTagType = .FLOAT

    public var name: String = ""
    public var value: ValueType

    public init(name: String = "", value: ValueType) {
        self.name = name
        self.value = value
    }

    public init(body buf: inout NIOCore.ByteBuffer, endianness: Endianness) throws {
        self.value = Float(bitPattern: buf.readInteger(endianness: endianness)!)
    }

    public func encodeBody(_ buf: inout ByteBuffer) {
        buf.writeInteger(self.value.bitPattern, endianness: .little)
    }
}