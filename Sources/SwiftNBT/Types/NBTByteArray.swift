import NIOCore

public struct NBTByteArray: NBTEncodable, ExpressibleByArrayLiteral {
    public typealias ArrayLiteralElement = Int8
    public typealias ValueType = [Int8]

    public let tagType: NBTTagType = .BYTE_ARRAY

    public var name: String = ""
    public var value: [Int8]

    public init(arrayLiteral elements: Int8...) {
        self.value = elements
    }

    public init(name: String = "", value: ValueType) {
        self.name = name
        self.value = value
    }
}