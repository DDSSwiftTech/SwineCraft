import NIOCore

public struct NBTIntArray: NBTEncodable {
    public typealias ValueType = [Int32]

    public let tagType: NBTTagType = .INT_ARRAY

    public var name: String
    public var value: [Int32]

    public init(name: String = "", value: ValueType) {
        self.name = name
        self.value = value
    }
}