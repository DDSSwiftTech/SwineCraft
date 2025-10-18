import NIOCore

public struct NBTCompound: NBTEncodable {
    public typealias ValueType = [any NBTEncodable]
    
    public let tagType: NBTTagType = .COMPOUND
    
    public var name: String
    public var value: ValueType = []

    public init(name: String = "", _ contents: any NBTEncodable & Sendable...) {
        self.name = name
        self.value += contents
    }

    public init(name: String, value: ValueType) {
        self.name = name
        self.value = value
    }

    public init(body buf: inout ByteBuffer) throws {
        self.name = ""
        
        while let tagTypeInt: UInt8 = buf.peekInteger(),
        let tagType = NBTTagType(rawValue: tagTypeInt) {
            var endLoop = false

            switch tagType {
                case .BYTE:
                    self.value.append(try NBTByte(full: &buf))
                case .BYTE_ARRAY:
                    self.value.append(try NBTByteArray(full: &buf))
                case .COMPOUND:
                    self.value.append(try NBTCompound(full: &buf))
                case .DOUBLE:
                    self.value.append(try NBTDouble(full: &buf))
                case .END:
                    let _: UInt8? = buf.readInteger() // dispose of end tag from buf
                    endLoop = true
                case .FLOAT:
                    self.value.append(try NBTFloat(full: &buf))
                case .INT:
                    self.value.append(try NBTInt(full: &buf))
                case .INT_ARRAY:
                    self.value.append(try NBTIntArray(full: &buf))
                case .LIST:
                    self.value.append(try NBTList(full: &buf))
                case .LONG:
                    self.value.append(try NBTLong(full: &buf))
                case .LONG_ARRAY:
                    self.value.append(try NBTLongArray(full: &buf))
                case .SHORT:
                    self.value.append(try NBTShort(full: &buf))
                case .STRING:
                    self.value.append(try NBTString(full: &buf))
            }

            if endLoop {
                break
            }
        }
    }

    public func encodeBody(_ buf: inout ByteBuffer) {
        for item in self.value {
            item.encodeFull(&buf)
        }

        buf.writeInteger(UInt8(0)) // "End tag", otherwise known as a null byte
    }

    public mutating func addValues(_ vals: any NBTEncodable...) {
        self.value += vals
    }
}