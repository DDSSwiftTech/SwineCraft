import NIOCore

public struct NBTLongArray: NBTEncodable {
    public typealias ValueType = [Int64]

    public let tagType: NBTTagType = .LONG_ARRAY

    public var name: String
    public var value: [Int64]

    public init(name: String = "", value: ValueType) {
        self.name = name
        self.value = value
    }
}