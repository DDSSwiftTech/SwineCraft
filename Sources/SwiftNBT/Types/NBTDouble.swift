import NIOCore

struct NBTDouble: NBTEncodable {
    typealias ValueType = Double

    let tagType: NBTTagType = .DOUBLE

    var name: String = ""
    var value: ValueType

    init(name: String, value: Double) {
        self.name = name
        self.value = value
    }

    init(body buf: inout NIOCore.ByteBuffer, endianness: Endianness) throws {
        self.value = Double(bitPattern: buf.readInteger(endianness: endianness)!)
    }

    func encodeBody(_ buf: inout ByteBuffer) {
        buf.writeInteger(self.value.bitPattern, endianness: .little)
    }
}