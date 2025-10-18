import NIOCore

struct NBTByte: NBTEncodable {
    typealias ValueType = Int8

    let tagType: NBTTagType = .BYTE

    var name: String = ""
    var value: ValueType
}