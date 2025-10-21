import NIOCore

public struct NBTInt: NBTEncodable {
    public typealias ValueType = Int32

    public let tagType: NBTTagType = .INT

    public var name: String = ""
    public var value: ValueType

    public init(name: String = "", value: ValueType) {
        self.name = name
        self.value = value
    }
}