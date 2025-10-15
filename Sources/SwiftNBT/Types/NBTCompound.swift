import NIOCore

public struct NBTCompound: NBTEncodable {
    public typealias ValueType = [any NBTEncodable]
    
    static public let tagType: NBTTagType = .COMPOUND
    
    public var name: String
    public var value: ValueType = []

    public static func == (lhs: NBTCompound, rhs: NBTCompound) -> Bool {
        // lhs.name == rhs.name && {
        for idx in 0..<lhs.value.count {
            let lvalue = lhs.value[idx]
            let rvalue = lhs.value[idx]
            switch type(of: lvalue) {
                case is NBTByte.Type:
                    if lvalue as? NBTByte != rvalue as? NBTByte {
                        return false
                    }
                case is NBTByteArray.Type:
                    if lvalue as? NBTByteArray != rvalue as? NBTByteArray {
                        return false
                    }
                case is NBTCompound.Type:
                    if lvalue as? NBTCompound != rvalue as? NBTCompound {
                        return false
                    }
                case is NBTDouble.Type:
                    if lvalue as? NBTDouble != rvalue as? NBTDouble {
                        return false
                    }
                case is NBTFloat.Type:
                    if lvalue as? NBTFloat != rvalue as? NBTFloat {
                        return false
                    }
                case is NBTInt.Type:
                    if lvalue as? NBTInt != rvalue as? NBTInt {
                        return false
                    }
                case is NBTIntArray.Type:
                    if lvalue as? NBTIntArray != rvalue as? NBTIntArray {
                        return false
                    }
                case is NBTLong.Type:
                    if lvalue as? NBTLong != rvalue as? NBTLong {
                        return false
                    }
                case is NBTLongArray.Type:
                    if lvalue as? NBTLongArray != rvalue as? NBTLongArray {
                        return false
                    }
                case is NBTShort.Type:
                    if lvalue as! NBTShort != rvalue as! NBTShort {
                        return false
                    }
                case is NBTString.Type:
                    if lvalue as! NBTString != rvalue as! NBTString {
                        return false
                    }
                default:
                    return false
            }
        }

        return true
    }

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
                    break
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