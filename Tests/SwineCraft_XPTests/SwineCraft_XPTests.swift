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
        NBTString(name: "myText", value: "My NBT text"),
        NBTInt(name: "my Int32 Number", value: 456),
        NBTIntArray(name: "ints", 1, 2, 3, 4, 5)
    )
    
    var buf = ByteBuffer()

    compound.encodeFull(&buf)

    print(buf)
}