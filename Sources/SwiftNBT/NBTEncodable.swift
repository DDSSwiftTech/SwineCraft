import NIOCore

public protocol NBTEncodable: Sendable, Equatable {
    associatedtype ValueType

    static var tagType: NBTTagType { get }

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
        buf.writeInteger(Self.tagType.rawValue)
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

extension NBTEncodable where ValueType: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.value == rhs.value &&
        lhs.name == rhs.name &&
        type(of: lhs).tagType == type(of: rhs).tagType
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