import NIOCore

struct NBTString: NBTEncodable {

    typealias ValueType = String

    let tagType: NBTTagType = .STRING

    var name: String = ""
    var value: ValueType

    init(name: String, value: String) {
        self.name = name
        self.value = value
    }

    init(body buf: inout NIOCore.ByteBuffer) throws {
        guard let stringLength: UInt16 = buf.readInteger(endianness: .little),
        let decodedString = buf.readString(length: Int(stringLength)) else {
            throw NBTError.BUFFER_DECODE(reason: .STRING)
        }

        self.name = ""
        self.value = decodedString
    }

    func encodeBody(_ buf: inout NIOCore.ByteBuffer) {
        buf.writeInteger(UInt16(self.value.utf8.count), endianness: .little)
        buf.writeString(self.value)
    }

}