import NIOCore

struct NBTIntArray: NBTEncodable {
    typealias ValueType = [Int32]

    static let tagType: NBTTagType = .INT_ARRAY

    var name: String
    var value: [Int32]
}