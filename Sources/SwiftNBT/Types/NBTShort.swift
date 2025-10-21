import NIOCore

public struct NBTShort: NBTEncodable {
    public typealias ValueType = Int16

    public let tagType: NBTTagType = .SHORT

    public var name: String = ""
    public var value: ValueType

    public init(name: String = "", value: ValueType) {
        self.name = name
        self.value = value
    }
}