import NIOCore

struct NBTList<T>: NBTEncodable where T: NBTEncodable {
    typealias ValueType = [T]

    static var tagType: NBTTagType { .LIST }

    var name: String
    var value: [T]

    init(name: String = "", _ value: T...) {
        self.name = name
        self.value = value
    }

    init(name: String, value: [T]) {
        self.name = name
        self.value = value
    }

    func encodeBody(_ buf: inout NIOCore.ByteBuffer) {
        buf.writeInteger(Self.ValueType.Element.tagType.rawValue)
        buf.writeInteger(UInt32(self.value.count), endianness: .little)
        
        for item in value {
            item.encodeBody(&buf)
        }
    }
}