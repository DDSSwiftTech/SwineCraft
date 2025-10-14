import NIOCore

struct NBTInt: NBTEncodable {
    typealias ValueType = Int32

    let tagType: NBTTagType = .INT

    var name: String = ""
    var value: ValueType
}