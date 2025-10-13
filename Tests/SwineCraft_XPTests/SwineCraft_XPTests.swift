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
    let compound = try NBTNode(NBTCompound(
        NBTNode(name: "myText", "My NBT text"),
        NBTNode(name: "my Int32 Number", Int32(456)),
        NBTNode(name: "Some List", NBTList(
            NBTNode(Int8(5)),
            NBTNode(Int8(5))
        )),
        NBTNode(name: "AnotherCompound", NBTCompound(
            NBTNode(name: "Hello", Int8(30))
        ))
    ))

    dump(compound.encodeNBT())
}