import NIOCore

public struct NBTByte: NBTEncodable, ExpressibleByIntegerLiteral {
    public typealias IntegerLiteralType = Int8
    public typealias ValueType = Int8

    public let tagType: NBTTagType = .BYTE

    public var name: String = ""
    public var value: ValueType

    public init(integerLiteral value: Int8) {
        self.value = value
    }

    public init(name: String = "", value: ValueType) {
        self.name = name
        self.value = value
    }
}