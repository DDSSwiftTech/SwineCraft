import NIOCore

struct NBTShort: NBTEncodable {
    typealias ValueType = Int16

    static let tagType: NBTTagType = .SHORT

    var name: String = ""
    var value: ValueType
}