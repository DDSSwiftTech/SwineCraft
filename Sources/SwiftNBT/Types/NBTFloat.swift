import NIOCore

struct NBTFloat: NBTEncodable {
    typealias ValueType = Float

    static let tagType: NBTTagType = .FLOAT

    var name: String = ""
    var value: ValueType

    func encodeBody(_ buf: inout ByteBuffer) {
        buf.writeInteger(self.value.bitPattern, endianness: .little)
    }
}