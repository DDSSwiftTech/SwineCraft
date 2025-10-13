import NIOCore

public struct NBTNode: Sendable {
    var tagType: NBTTagType
    private var name: String = ""

    private var int8Val: Int8?
    private var int16Val: Int16?
    private var int32Val: Int32?
    private var int64Val: Int64?
    private var floatVal: Float?
    private var doubleVal: Double?
    private var stringVal: String?
    private var listVal: NBTList?
    private var compoudVal: NBTCompound?

    init(name: String = "", _ value: Int8) {
        self.int8Val = value
        self.tagType = .BYTE
        self.name = name
    }

    init(name: String = "", _ value: Int16) {
        self.int16Val = value
        self.tagType = .SHORT
        self.name = name
    }

    init(name: String = "", _ value: Int32) {
        self.int32Val = value
        self.tagType = .INT
        self.name = name
    }

    init(name: String = "", _ value: Int64) {
        self.int64Val = value
        self.tagType = .LONG
        self.name = name
    }

    init(name: String = "", _ value: Float) {
        self.floatVal = value
        self.tagType = .FLOAT
        self.name = name
    }

    init(name: String = "", _ value: Double) {
        self.doubleVal = value
        self.tagType = .DOUBLE
        self.name = name
    }

    init(name: String = "", _ value: String) {
        self.stringVal = value
        self.tagType = .STRING
        self.name = name
    }

    init(name: String = "", _ value: NBTList) {
        self.listVal = value

        switch value.itemType {
            case .BYTE:
                self.tagType = .BYTE_ARRAY
            case .INT:
                self.tagType = .INT_ARRAY
            case .LONG:
                self.tagType = .LONG_ARRAY
            default:
                self.tagType = .LIST
        }

        self.name = name
    }

    init(name: String = "", _ value: NBTCompound) {
        self.compoudVal = value
        self.tagType = .COMPOUND
        self.name = name
    }

    func get() -> Int8? {
        return self.int8Val
    }

    func get() -> Int16? {
        return self.int16Val
    }

    func get() -> Int32? {
        return self.int32Val
    }

    func get() -> Int64? {
        return self.int64Val
    }

    func get() -> Float? {
        return self.floatVal
    }

    func get() -> Double? {
        return self.doubleVal
    }

    func get() -> String? {
        return self.stringVal
    }

    func get() -> NBTList? {
        return self.listVal
    }

    func get() -> NBTCompound? {
        return self.compoudVal
    }

    func getName() -> String? {
        return self.name
    }
    
    func getType() -> NBTTagType {
        return self.tagType
    }

    func encodeNBT() -> ByteBuffer {
        var buf = ByteBuffer(integer: self.tagType.rawValue)

        buf.writeInteger(UInt16(self.name.utf8.count), endianness: .little)
        buf.writeString(self.name)

        encodeBody(&buf)

        return buf
    }

    func encodeBody(_ buf: inout ByteBuffer) {
        switch self.tagType {
            case .BYTE:
                buf.writeInteger(self.int8Val!, endianness: .little)
            case .SHORT:
                buf.writeInteger(self.int16Val!, endianness: .little)
            case .INT:
                buf.writeInteger(self.int32Val!, endianness: .little)
            case .LONG:
                buf.writeInteger(self.int64Val!, endianness: .little)
            case .FLOAT:
                var floatBuf = withUnsafeBytes(of: self.floatVal) {ByteBuffer(bytes: $0)}
                buf.writeBuffer(&floatBuf)
            case .DOUBLE:
                var doubleBuf = withUnsafeBytes(of: self.doubleVal) {ByteBuffer(bytes: $0)}
                buf.writeBuffer(&doubleBuf)
            case .STRING:
                buf.writeInteger(UInt16(self.stringVal!.utf8.count), endianness: .little)
                buf.writeString(self.stringVal!)
            case .COMPOUND:
                self.compoudVal!.encodeBody(&buf)
            case .LIST:
                let itemType = self.listVal!.itemType!
                
                buf.writeInteger(itemType.rawValue)
                fallthrough
            case .BYTE_ARRAY, .INT_ARRAY, .LONG_ARRAY:
                buf.writeInteger(UInt32(self.listVal!.listItems.count), endianness: .little)
                for item in self.listVal!.listItems {
                    item.encodeBody(&buf)
                }
            default:
                break // need to finish implementing
        }
    }
}

extension NBTNode: Equatable {
    public static func == (lhs: NBTNode, rhs: NBTNode) -> Bool {
        lhs.int8Val == rhs.int8Val &&
        lhs.int16Val == rhs.int16Val &&
        lhs.int32Val == rhs.int32Val && 
        lhs.int64Val == rhs.int64Val &&
        lhs.floatVal == rhs.floatVal &&
        lhs.doubleVal == rhs.doubleVal &&
        lhs.stringVal == rhs.stringVal &&
        lhs.listVal == rhs.listVal &&
        lhs.compoudVal == rhs.compoudVal
    }

}