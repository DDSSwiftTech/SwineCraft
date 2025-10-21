import NIOCore

public struct NBTByteArray: NBTEncodable {
    public typealias ValueType = [Int8]

    public let tagType: NBTTagType = .BYTE_ARRAY

    public var name: String
    public var value: [Int8]

    public init(name: String = "", value: ValueType) {
        self.name = name
        self.value = value
    }
}