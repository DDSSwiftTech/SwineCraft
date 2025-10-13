import NIOCore

struct NBTList {
    var listItems: [NBTNode] = []
    var itemType: NBTTagType? = nil
    
    init(_ listItem: NBTNode...) throws {
        for item in listItem {
            try self.addElement(item)
        }
    }

    mutating func addElement(_ val: NBTNode) throws {
        guard self.itemType == nil || self.itemType == val.tagType else {
            throw NBTInvalidListElement.Value(val)
        }

        self.listItems.append(val)
        self.itemType = val.tagType
    }

    mutating func addElements(_ vals: NBTNode...) throws {
        for val in vals {
            try self.addElement(val)
        }
    }

    // func encodeNBT() -> ByteBuffer {
    //     for item in self.listItems {
    //         item.encodeNBTListElement(buf: &buf)
    //     }

    //     return buf
    // }

    // func encodeNBTCompoundValue(_ buf: inout ByteBuffer) {
    //     for item in self.listItems {
    //         item.encodeNBTListElement(buf: &buf)
    //     }

    //     return buf
    // }

    // func encodeListElement(_ buf: inout ByteBuffer) {
    //     if self.tagType == .LIST {
    //         buf.writeInteger(self.listItems.first?.tagType.rawValue ?? NBTTagType.END.rawValue)
    //     }

    //     buf.writeInteger(UInt16(self.listItems.count), endianness: .little)

    //     for item in self.listItems {
    //         item.encodeListElement(&buf)
    //     }
    // }
}