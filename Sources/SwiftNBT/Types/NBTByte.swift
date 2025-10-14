import NIOCore

struct NBTByte: NBTEncodable {
    typealias ValueType = Int8

    static let tagType: NBTTagType = .BYTE

    var name: String = ""
    var value: ValueType
}