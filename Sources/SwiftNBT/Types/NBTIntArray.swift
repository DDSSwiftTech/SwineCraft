import NIOCore

public struct NBTIntArray: NBTEncodable, ExpressibleByArrayLiteral {
    public typealias ArrayLiteralElement = Int32

    public typealias ValueType = [Int32]

    public let tagType: NBTTagType = .INT_ARRAY

    public var name: String = ""
    public var value: [Int32]

    public init(arrayLiteral elements: Int32...) {
        self.value = elements
    }

    public init(name: String = "", value: ValueType) {
        self.name = name
        self.value = value
    }
}