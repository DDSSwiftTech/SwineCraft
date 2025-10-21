import NIOCore

public struct NBTByte: NBTEncodable {
    public typealias ValueType = Int8

    public let tagType: NBTTagType = .BYTE

    public var name: String = ""
    public var value: ValueType

    public init(name: String = "", value: ValueType) {
        self.name = name
        self.value = value
    }
}