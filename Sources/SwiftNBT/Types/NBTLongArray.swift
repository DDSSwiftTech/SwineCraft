import NIOCore

struct NBTLongArray: NBTEncodable {
    typealias ValueType = [Int64]

    let tagType: NBTTagType = .LONG_ARRAY

    var name: String
    var value: [Int64]
}