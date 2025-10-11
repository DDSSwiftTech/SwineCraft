import NIOCore
import Foundation
import Testing
@testable import SwineCraft_XP

@Test func example() async throws {
    // Write your test here and use APIs like `#expect(...)` to check expected conditions.
}

@Test func deflateInflateCompressDecompress() async throws {
    let compressor = DeflateCompressor()
    let decompressor = InflateDecompressor()

    var data = ByteBuffer(bytes: [UInt8](repeating: 0, count: 5000) + [UInt8](repeating: 1, count: 5000) + [UInt8](repeating: 2, count: 5000))

    print("TESTING WITH DATA: \(data)")

    let originalData = data

    var compressedData = compressor.compress(&data)
    let decompressedData = decompressor.decompress(&compressedData)

    #expect(originalData == decompressedData, "Original data == compressed data")
}