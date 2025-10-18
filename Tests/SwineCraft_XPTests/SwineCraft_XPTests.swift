import NIOCore
import Foundation
import Testing
@testable import SwineCraft_XP
@testable import SwiftNBT

@Test func example() async throws {
    // Write your test here and use APIs like `#expect(...)` to check expected conditions.
}

@Test func deflateInflateCompressDecompress() async throws {
    let compressor = DeflateCompressor()
    let decompressor = InflateDecompressor()

    var data = ByteBuffer(bytes: [UInt8](repeating: 0, count: 5000) + [UInt8](repeating: 1, count: 5000) + [UInt8](repeating: 2, count: 5000))

    let originalData = data

    var compressedData = compressor.compress(&data)
    let decompressedData = decompressor.decompress(&compressedData)

    #expect(originalData == decompressedData, "Original data == compressed data")
}

@Test func snappyCompressDecompress() async throws {
    let compressor = SnappyCompressor()
    let decompressor = SnappyDecompressor()

    var data = ByteBuffer(bytes: [UInt8](repeating: 0, count: 5000) + [UInt8](repeating: 1, count: 5000) + [UInt8](repeating: 2, count: 5000))

    let originalData = data

    var compressedData = compressor.compress(&data)
    let decompressedData = decompressor.decompress(&compressedData)

    #expect(originalData == decompressedData, "Original data == compressed data")
}

@Test func NBTTest() async throws {
    let compound = NBTCompound(
        NBTByte(name: "TestB", value: 20),
        NBTByteArray(name: "TestBA", value: [1, 2, 3]),
        NBTCompound(name: "TestC", NBTCompound()),
        NBTDouble(name: "TestD", value: 3.3),
        NBTFloat(name: "TestF", value: 3.3),
        NBTInt(name: "TestI", value: 500),
        NBTIntArray(name: "TestIA", value: [1, 2, 3]),
        NBTLong(name: "TestL", value: 3000),
        NBTLongArray(name: "TestLA", value: [1, 2, 3]),
        NBTShort(name: "TestSI", value: 4040),
        NBTString(name: "TestS", value: "hello"),
        NBTList(name: "TestLIST", value: [NBTShort(value: 5), NBTShort(value: 10)])
    )
    
    var buf = ByteBuffer()

    try compound.encodeFull(&buf)

    let decodedCompound = try NBTCompound(full: &buf, endianness: .little)

    #expect(compound == decodedCompound, "compound decoded: \(decodedCompound)")

    let unequalCompound = NBTCompound(
        NBTByte(name: "TestB", value: 22),
        NBTByteArray(name: "TestBA", value: [1, 2, 3, 4]),
        NBTCompound(name: "TestC", NBTCompound()),
        NBTDouble(name: "TestD", value: 3.4),
        NBTFloat(name: "TestF", value: 3.4),
        NBTInt(name: "TestI", value: 501),
        NBTIntArray(name: "TestIA", value: [1, 2, 3, 4]),
        NBTLong(name: "TestL", value: 3001),
        NBTLongArray(name: "TestLA", value: [1, 2, 3, 4]),
        NBTShort(name: "TestSI", value: 4041),
        NBTString(name: "TestS", value: "hello world"),
        NBTList(name: "TestLIST", value: [NBTShort(value: 6), NBTShort(value: 11)])
    )

    #expect(compound != unequalCompound)
}

@Test func NBTFileTest() async throws {
    let fileURL = URL(filePath: "/" + #filePath.split(separator: "/").dropLast().joined(separator: "/") + "/level.dat")

    let nbtFileCompound = try NBTCompound(fromFile: fileURL)

    var encodedbuffer = ByteBuffer()

    try nbtFileCompound.encodeFile(&encodedbuffer)

    #expect(ByteBuffer(bytes: try Data(contentsOf: fileURL)) == encodedbuffer)
}