import NIOCore
import Foundation


public struct NBTList: NBTEncodable, ExpressibleByArrayLiteral {
    public typealias ArrayLiteralElement = any NBTEncodable
    public typealias ValueType = [any NBTEncodable]

    public var tagType: NBTTagType { .LIST }
    public var value: ValueType = []
    public var name: String = ""

    public init(arrayLiteral elements: any NBTEncodable...) {
        self.value = elements
    }

    public init(name: String = "", value: [any NBTEncodable]) throws {
        self.name = name

        // check that they're all the same type if there's more than one element
        // Must be the case for a List, and can't use Some...
        if value.count > 1 {
            let firstElemType = type(of: value.first!)

            guard value.allSatisfy({ (item) in
                type(of: item) == firstElemType
            }) else {
                throw NBTError.BUFFER_DECODE(reason: .LIST_ELEMENTS_DONT_MATCH)
            }
        }

        self.value = value
    }

    public init(body buf: inout ByteBuffer, endianness: Endianness) throws {
        self.name = ""

        guard let elemTagTypeRaw: UInt8 = buf.readInteger(),
        let elemTagType: NBTTagType = NBTTagType(rawValue: elemTagTypeRaw),
        let count = buf.readInteger(endianness: endianness) as UInt32? else {
            throw NBTError.BUFFER_DECODE(reason: .TAG_TYPE)
        }

        for _ in 0..<count {
            let elementType: any NBTEncodable.Type

            elementType = try {
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
                        // This case is only possible, if the element type is specified as END
                        // and there is a non-zero count. That should not be possible, so throw.
                        throw NBTError.BUFFER_DECODE(reason: .TAG_TYPE)
                }
            }()

            self.value.append(try elementType.init(body: &buf, endianness: endianness))
        }
    }


    public func encodeBody(_ buf: inout NIOCore.ByteBuffer) throws {
        let elementTagType: NBTTagType = try {
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
                    throw NBTError.BUFFER_DECODE(reason: .TAG_TYPE) // should not be possible
            }
        }()
        buf.writeInteger(elementTagType.rawValue)
        buf.writeInteger(UInt32(self.value.count), endianness: .little)
        
        for item in value {
            try item.encodeBody(&buf)
        }
    }
}