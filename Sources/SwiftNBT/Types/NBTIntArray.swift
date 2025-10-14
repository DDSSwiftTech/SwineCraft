import NIOCore

struct NBTIntArray: NBTEncodable {
    typealias ValueType = [Int32]

    static let tagType: NBTTagType = .INT_ARRAY

    var name: String
    var value: [Int32]

    init(name: String = "", _ value: Int32...) {
        self.name = name
        self.value = value
    }

    init(name: String, value: [Int32]) {
        self.name = name
        self.value = value
    }

    func encodeBody(_ buf: inout NIOCore.ByteBuffer) {
        buf.writeInteger(UInt32(self.value.count), endianness: .little)
        
        for item in value {
            buf.writeInteger(item, endianness: .little)
        }
    }
}