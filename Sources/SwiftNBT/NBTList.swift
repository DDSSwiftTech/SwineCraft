import NIOCore

struct NBTList: Equatable {
    var listItems: [NBTNode] = []
    var itemType: NBTTagType? = nil
    
    init(_ listItem: NBTNode...) throws {
        for item in listItem {
            try self.addElement(item)
        }
    }

    mutating func addElement(_ val: NBTNode) throws {
        guard self.itemType == nil || self.itemType == val.tagType else {
            throw NBTError.ListValue(val)
        }

        self.listItems.append(val)
        self.itemType = val.tagType
    }

    mutating func addElements(_ vals: NBTNode...) throws {
        for val in vals {
            try self.addElement(val)
        }
    }
}