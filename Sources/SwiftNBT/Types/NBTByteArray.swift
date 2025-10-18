import NIOCore

struct NBTByteArray: NBTEncodable {
    typealias ValueType = [Int8]

    let tagType: NBTTagType = .BYTE_ARRAY

    var name: String
    var value: [Int8]
}