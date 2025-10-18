import NIOCore

struct NBTLong: NBTEncodable {
    typealias ValueType = Int64

    let tagType: NBTTagType = .LONG

    var name: String = ""
    var value: ValueType
}