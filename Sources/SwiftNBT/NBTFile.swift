import Foundation
import NIOCore

public struct NBTFile {
    public let fileCompound: NBTCompound
    private var fileVersion: UInt32

    public init(fromFile fileURL: URL) throws {
        guard let nbtFileData = FileManager.default.contents(atPath: fileURL.path) else {
            throw NBTError.BUFFER_DECODE(reason: .CORRUPT_FILE)
        }

        try self.init(fromData: nbtFileData)
    }

    public init(fromData data: Data) throws {
        var buf = ByteBuffer(bytes: data)

        try self.init(fromBuffer: &buf)
    }

    public init(fromBuffer buf: inout ByteBuffer) throws {
        guard let fileVersion: UInt32 = buf.readInteger(endianness: .little) else {
            throw NBTError.BUFFER_DECODE(reason: .CORRUPT_FILE)
        }

        print("FILE VERSION: \(fileVersion)")
        
        let bufExpectedLength: UInt32 = buf.readInteger(endianness: .little)!

        guard buf.readableBytes == bufExpectedLength else {
            throw NBTError.BUFFER_DECODE(reason: .CORRUPT_FILE)
        }

        self.fileCompound = try NBTCompound(full: &buf, endianness: .little)

        self.fileVersion = fileVersion
    }

    public func encode(_ outbuf: inout ByteBuffer) throws {
        var buf = ByteBuffer()

        try self.fileCompound.encodeFull(&buf)

        outbuf.writeInteger(self.fileVersion ?? 10, endianness: .little)
        outbuf.writeInteger(UInt32(buf.readableBytes), endianness: .little)
        outbuf.writeBuffer(&buf)
    }
}