import NIOCore

public struct NBTLong: NBTEncodable, ExpressibleByIntegerLiteral {
    public typealias IntegerLiteralType = Int64

    public typealias ValueType = Int64

    public let tagType: NBTTagType = .LONG

    public var name: String = ""
    public var value: ValueType

    public init(name: String = "", value: ValueType) {
        self.name = name
        self.value = value
    }

    public init(integerLiteral value: Int64) {
        self.value = value
    }
}