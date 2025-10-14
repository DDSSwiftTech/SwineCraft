import NIOCore

struct NBTByteArray: NBTEncodable {
    typealias ValueType = [Int8]

    let tagType: NBTTagType = .BYTE_ARRAY

    var name: String
    var value: [Int8]

    init(name: String = "", _ value: Int8...) {
        self.name = name
        self.value = value
    }
    
    init(name: String, value: ValueType) {
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