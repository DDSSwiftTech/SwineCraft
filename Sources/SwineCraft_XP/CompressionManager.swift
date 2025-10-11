import NIOCore

class CompressionManager {
    let compressionThreshold: Int
    private let compressor: Compressor
    private let decompressor: Decompressor

    init<C, D>(compressor: C, decompressor: D, compressionThreshold: Int = 256) where C: Compressor, D: Decompressor {
        self.compressor = compressor
        self.decompressor = decompressor
        self.compressionThreshold = compressionThreshold
    }

    func compress(_ buffer: inout ByteBuffer) -> ByteBuffer {
        return self.compressor.compress(&buffer)
    }
    func decompress(_ buffer: inout ByteBuffer) -> ByteBuffer {
        return self.decompressor.decompress(&buffer)
    }
}