import NIOCore

public struct NBTLongArray: NBTEncodable, ExpressibleByArrayLiteral {
    public typealias ArrayLiteralElement = Int64
    public typealias ValueType = [Int64]

    public let tagType: NBTTagType = .LONG_ARRAY

    public var name: String = ""
    public var value: [Int64]

    public init(arrayLiteral elements: Int64...) {
        self.value = elements
    }

    public init(name: String = "", value: ValueType) {
        self.name = name
        self.value = value
    }
}