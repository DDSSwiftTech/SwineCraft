import NIOCore

public struct NBTDouble: NBTEncodable {
    public typealias ValueType = Double

    public let tagType: NBTTagType = .DOUBLE

    public var name: String = ""
    public var value: ValueType

    public init(name: String = "", value: ValueType) {
        self.name = name
        self.value = value
    }

    public init(body buf: inout NIOCore.ByteBuffer, endianness: Endianness) throws {
        self.value = Double(bitPattern: buf.readInteger(endianness: endianness)!)
    }

    public func encodeBody(_ buf: inout ByteBuffer) {
        buf.writeInteger(self.value.bitPattern, endianness: .little)
    }
}