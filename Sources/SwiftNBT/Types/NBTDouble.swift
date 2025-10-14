import NIOCore

struct NBTDouble: NBTEncodable {
    typealias ValueType = Double

    let tagType: NBTTagType = .DOUBLE

    var name: String = ""
    var value: ValueType

    func encodeBody(_ buf: inout ByteBuffer) {
        buf.writeInteger(self.value.bitPattern, endianness: .little)
    }
}