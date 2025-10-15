// import NIOCore

// protocol NBTList: NBTEncodable {
//     associatedtype Element: NBTEncodable

//     init()
// }

// extension NBTList where ValueType: MutableCollection, ValueType.Element: NBTEncodable {
//     static var tagType: NBTTagType { .LIST }

//     func encodeBody(_ buf: inout NIOCore.ByteBuffer) {
//         buf.writeInteger(Self.ValueType.Element.tagType.rawValue)
//         buf.writeInteger(UInt32(self.value.count), endianness: .little)
        
//         for item in value {
//             item.encodeBody(&buf)
//         }
//     }

//     init(body buf: inout ByteBuffer) throws {
//         self.init()
//         self.name = ""
//         self.value = 
//         buf.writeBytes(Sequence)
//     }
// }

// struct NBTList_Byte: NBTList {
//     init(name: String, value: [Element]) {
//         self.name = name
//         self.value = value
//     }

//     typealias Element = NBTByte
//     typealias ValueType = [Element]

//     var value: [Element]

//     var name: String

//     init() {
//         self.name = ""
//         self.value = []
//     }

//     func encodeBody(_ buf: inout NIOCore.ByteBuffer) {
        
//     }

    
// }