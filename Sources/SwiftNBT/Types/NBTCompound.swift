import NIOCore
import Foundation

public struct NBTCompound: NBTEncodable {
    public typealias ValueType = [any NBTEncodable]
    
    public let tagType: NBTTagType = .COMPOUND
    
    public var name: String
    public var value: ValueType = []
    private var fileVersion: UInt32? = nil

    public init(name: String = "", _ contents: any NBTEncodable & Sendable...) {
        self.name = name
        self.value += contents
    }

    public init(name: String, value: ValueType) {
        self.name = name
        self.value = value
    }

    public init(fromFile fileURL: URL) throws {
        guard let nbtFileData = FileManager.default.contents(atPath: fileURL.path) else {
            throw NBTError.BUFFER_DECODE(reason: .CORRUPT_FILE)
        }

        var buf = ByteBuffer(bytes: nbtFileData)

        guard let fileVersion: UInt32 = buf.readInteger(endianness: .little) else {
            throw NBTError.BUFFER_DECODE(reason: .CORRUPT_FILE)
        }

        print("FILE VERSION: \(fileVersion)")
        
        let bufExpectedLength: UInt32 = buf.readInteger(endianness: .little)!

        guard buf.readableBytes == bufExpectedLength else {
            throw NBTError.BUFFER_DECODE(reason: .CORRUPT_FILE)
        }

        try self.init(full: &buf, endianness: .little)

        self.fileVersion = fileVersion
    }

    public init(body buf: inout ByteBuffer, endianness: Endianness) throws {
        self.name = ""
        
        while let tagTypeInt: UInt8 = buf.peekInteger(),
        let tagType = NBTTagType(rawValue: tagTypeInt) {
            var endLoop = false

            switch tagType {
                case .BYTE:
                    self.value.append(try NBTByte(full: &buf, endianness: endianness))
                case .BYTE_ARRAY:
                    self.value.append(try NBTByteArray(full: &buf, endianness: endianness))
                case .COMPOUND:
                    self.value.append(try NBTCompound(full: &buf, endianness: endianness))
                case .DOUBLE:
                    self.value.append(try NBTDouble(full: &buf, endianness: endianness))
                case .END:
                    let _: UInt8? = buf.readInteger() // dispose of end tag from buf
                    endLoop = true
                case .FLOAT:
                    self.value.append(try NBTFloat(full: &buf, endianness: endianness))
                case .INT:
                    self.value.append(try NBTInt(full: &buf, endianness: endianness))
                case .INT_ARRAY:
                    self.value.append(try NBTIntArray(full: &buf, endianness: endianness))
                case .LIST:
                    self.value.append(try NBTList(full: &buf, endianness: endianness))
                case .LONG:
                    self.value.append(try NBTLong(full: &buf, endianness: endianness))
                case .LONG_ARRAY:
                    self.value.append(try NBTLongArray(full: &buf, endianness: endianness))
                case .SHORT:
                    self.value.append(try NBTShort(full: &buf, endianness: endianness))
                case .STRING:
                    self.value.append(try NBTString(full: &buf, endianness: endianness))
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

    public func encodeFile(_ outbuf: inout ByteBuffer) {
        var buf = ByteBuffer()

        self.encodeFull(&buf)

        outbuf.writeInteger(self.fileVersion ?? 10, endianness: .little)
        outbuf.writeInteger(UInt32(buf.readableBytes), endianness: .little)
        outbuf.writeBuffer(&buf)
    }

    public mutating func addValues(_ vals: any NBTEncodable...) {
        self.value += vals
    }
}