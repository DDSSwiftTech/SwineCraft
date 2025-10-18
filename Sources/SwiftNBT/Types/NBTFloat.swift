import NIOCore

struct NBTFloat: NBTEncodable {
    typealias ValueType = Float

    let tagType: NBTTagType = .FLOAT

    var name: String = ""
    var value: ValueType

    init(name: String, value: Float) {
        self.name = name
        self.value = value
    }

    init(body buf: inout NIOCore.ByteBuffer) throws {
        self.value = Float(bitPattern: buf.readInteger(endianness: .little)!)
    }

    func encodeBody(_ buf: inout ByteBuffer) {
        buf.writeInteger(self.value.bitPattern, endianness: .little)
    }
}