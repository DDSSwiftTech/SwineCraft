import NIOCore

public struct NBTLong: NBTEncodable {
    public typealias ValueType = Int64

    public let tagType: NBTTagType = .LONG

    public var name: String = ""
    public var value: ValueType

    public init(name: String = "", value: ValueType) {
        self.name = name
        self.value = value
    }
}