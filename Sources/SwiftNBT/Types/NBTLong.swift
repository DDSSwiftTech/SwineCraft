import NIOCore

struct NBTLong: NBTEncodable {
    typealias ValueType = Int64

    static let tagType: NBTTagType = .LONG

    var name: String = ""
    var value: ValueType
}