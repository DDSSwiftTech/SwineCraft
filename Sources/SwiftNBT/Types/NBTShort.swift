import NIOCore

public struct NBTShort: NBTEncodable, ExpressibleByIntegerLiteral {
    public typealias IntegerLiteralType = Int16
    public typealias ValueType = Int16

    public let tagType: NBTTagType = .SHORT

    public var name: String = ""
    public var value: ValueType

    public init(integerLiteral value: Int16) {
        self.value = value
    }

    public init(name: String = "", value: ValueType) {
        self.name = name
        self.value = value
    }
}