import NIOCore

struct NBTLongArray: NBTEncodable {
    typealias ValueType = [Int64]

    let tagType: NBTTagType = .LONG_ARRAY

    var name: String
    var value: [Int64]

    init(name: String = "", _ value: Int64...) {
        self.name = name
        self.value = value
    }
    
    init(name: String, value: [Int64]) {
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