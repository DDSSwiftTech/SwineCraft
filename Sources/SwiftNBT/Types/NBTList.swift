import NIOCore


struct NBTList: NBTEncodable {
    typealias ValueType = [any NBTEncodable]

    var tagType: NBTTagType { .LIST }
    var value: ValueType = []
    var name: String

    init(name: String, value: [some NBTEncodable]) {
        self.name = name
        self.value = value
    }

    init(name: String, value: [any NBTEncodable]) {
        self.name = name
        self.value = value
    }

    init(body buf: inout ByteBuffer) throws {
        self.name = ""

        guard let elemTagTypeRaw: UInt8 = buf.readInteger(),
        let elemTagType: NBTTagType = NBTTagType(rawValue: elemTagTypeRaw),
        let count = buf.readInteger(endianness: .little) as UInt32? else {
            throw NBTError.BUFFER_DECODE(reason: .TAG_TYPE)
        }

        for _ in 0..<count {
            let elementType: any NBTEncodable.Type

            elementType = {
                switch elemTagType {
                    case .BYTE:
                        NBTByte.self
                    case .BYTE_ARRAY:
                        NBTByteArray.self
                    case .COMPOUND:
                        NBTCompound.self
                    case .DOUBLE:
                        NBTDouble.self
                    case .FLOAT:
                        NBTFloat.self
                    case .INT:
                        NBTInt.self
                    case .INT_ARRAY:
                        NBTIntArray.self
                    case .LIST:
                        NBTList.self
                    case .LONG:
                        NBTLong.self
                    case .LONG_ARRAY:
                        NBTLongArray.self
                    case .SHORT:
                        NBTShort.self
                    case .STRING:
                        NBTString.self
                    case .END:
                        NBTByte.self 
                }
            }()

            self.value.append(try elementType.init(body: &buf))
        }
    }


    func encodeBody(_ buf: inout NIOCore.ByteBuffer) {
        let elementTagType: NBTTagType = {
            switch self.value {
                case is [NBTByte]:
                    return .BYTE
                case is [NBTByteArray]:
                    return .BYTE_ARRAY
                case is [NBTCompound]:
                    return .COMPOUND
                case is [NBTDouble]:
                    return .DOUBLE
                case is [NBTFloat]:
                    return .FLOAT
                case is [NBTInt]:
                    return .INT
                case is [NBTIntArray]:
                    return .INT_ARRAY
                case is [NBTLong]:
                    return .LONG
                case is [NBTLongArray]:
                    return .LONG_ARRAY
                case is [NBTShort]:
                    return .SHORT
                case is [NBTString]:
                    return .STRING
                case is [NBTList]:
                    return .LIST
                default:
                    return .END
            }
        }()
        buf.writeInteger(elementTagType.rawValue)
        buf.writeInteger(UInt32(self.value.count), endianness: .little)
        
        for item in value {
            item.encodeBody(&buf)
        }
    }
}