import NIOCore

struct NBTString: NBTEncodable {
    typealias ValueType = String

    static let tagType: NBTTagType = .STRING

    var name: String = ""
    var value: ValueType

    func encodeBody(_ buf: inout NIOCore.ByteBuffer) {
        buf.writeInteger(UInt16(self.value.utf8.count), endianness: .little)
        buf.writeString(self.value)
    }
}