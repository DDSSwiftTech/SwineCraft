import NIOCore

public protocol NBTEncodable: Sendable, Equatable {
    associatedtype ValueType

    var tagType: NBTTagType { get }

    var name: String { get set }
    var value: ValueType { get set }

    init(name: String, value: ValueType)
    init(full buf: inout ByteBuffer) throws
    init(body buf: inout ByteBuffer) throws

    func encodeFull(_ buf: inout ByteBuffer)
    func encodeBody(_ buf: inout ByteBuffer)
}

extension NBTEncodable {
    public func encodeFull(_ buf: inout ByteBuffer) {
        buf.writeInteger(self.tagType.rawValue)
        buf.writeInteger(UInt16(self.name.utf8.count), endianness: .little)
        buf.writeString(self.name)

        self.encodeBody(&buf)
    }

    public init(full buf: inout ByteBuffer) throws {
        let _: UInt8? = buf.readInteger() // don't need tagtype here
        let stringLength: UInt16 = buf.readInteger(endianness: .little)!
        
        guard let name = buf.readString(length: Int(stringLength)) else {
            throw NBTError.BUFFER_DECODE(reason: .NAME_STRING)
        }

        self = try .init(body: &buf)

        self.name = name
    }
}

extension NBTEncodable where ValueType: RangeReplaceableCollection, ValueType.Element: FixedWidthInteger {
    func encodeBody(_ buf: inout NIOCore.ByteBuffer) {
        buf.writeInteger(UInt32(self.value.count), endianness: .little)
        
        for item in value {
            buf.writeInteger(item, endianness: .little)
        }
    }

    init(body buf: inout NIOCore.ByteBuffer) throws {
        guard let count: UInt32 = buf.readInteger(endianness: .little) else {
            throw NBTError.BUFFER_DECODE(reason: .ARRAY_COUNT)
        }

        var values = [] as! ValueType

        for _ in 0..<count {
            values.append(buf.readInteger(endianness: .little)!)
        }
        
        self.init(name: "", value: values)
    }
}

extension NBTEncodable where ValueType == Array<any NBTEncodable> {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        var elemComp: Bool = true

        for idx in 0..<lhs.value.count {
            switch lhs.value[idx] {
                case is NBTByte:
                    elemComp = lhs.value[idx] as? NBTByte == rhs.value[idx] as? NBTByte
                case is NBTByteArray:
                    elemComp = lhs.value[idx] as? NBTByteArray == rhs.value[idx] as? NBTByteArray
                case is NBTCompound:
                    elemComp = lhs.value[idx] as? NBTCompound == rhs.value[idx] as? NBTCompound
                case is NBTDouble:
                    elemComp = lhs.value[idx] as? NBTDouble == rhs.value[idx] as? NBTDouble
                case is NBTFloat:
                    elemComp = lhs.value[idx] as? NBTFloat == rhs.value[idx] as? NBTFloat
                case is NBTInt:
                    elemComp = lhs.value[idx] as? NBTInt == rhs.value[idx] as? NBTInt
                case is NBTIntArray:
                    elemComp = lhs.value[idx] as? NBTIntArray == rhs.value[idx] as? NBTIntArray
                case is NBTLong:
                    elemComp = lhs.value[idx] as? NBTLong == rhs.value[idx] as? NBTLong
                case is NBTLongArray:
                    elemComp = lhs.value[idx] as? NBTLongArray == rhs.value[idx] as? NBTLongArray
                case is NBTShort:
                    elemComp = lhs.value[idx] as? NBTShort == rhs.value[idx] as? NBTShort
                case is NBTString:
                    elemComp = lhs.value[idx] as? NBTString == rhs.value[idx] as? NBTString
                case is NBTList:
                    elemComp = lhs.value[idx] as? NBTList == rhs.value[idx] as? NBTList
                default:
                    elemComp = false
            }

            if !elemComp { break }
        }

        return lhs.name == rhs.name && lhs.tagType == rhs.tagType && elemComp
    }
}

extension NBTEncodable where ValueType: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.value == rhs.value &&
        lhs.name == rhs.name &&
        lhs.tagType == rhs.tagType
    }
}

extension NBTEncodable where ValueType: FixedWidthInteger {
    func encodeBody(_ buf: inout ByteBuffer) {
        buf.writeInteger(self.value, endianness: .little)
    }

    init(body buf: inout ByteBuffer) throws {
        self.init(name: "", value: buf.readInteger(endianness: .little)!)
    }
}