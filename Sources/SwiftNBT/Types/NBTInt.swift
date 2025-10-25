import NIOCore

public struct NBTInt: NBTEncodable, ExpressibleByIntegerLiteral {
    public typealias IntegerLiteralType = Int32
    public typealias ValueType = Int32

    public let tagType: NBTTagType = .INT

    public var name: String = ""
    public var value: ValueType

    public init(integerLiteral value: Int32) {
        self.value = value
    }

    public init(name: String = "", value: ValueType) {
        self.name = name
        self.value = value
    }
}