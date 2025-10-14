import NIOCore

public protocol NBTEncodable: Sendable {
    associatedtype ValueType

    var tagType: NBTTagType { get }
    var name: String { get set }
    var value: ValueType { get set }

    init(name: String, value: ValueType)

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
}