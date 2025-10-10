import NIOCore

class CompressionManager {
    let compressionThreshold = 256
    private let compressor: Compressor

    init<T>(compressor: T) where T: Compressor {
        self.compressor = compressor
    }

    func compress(_ buffer: inout ByteBuffer) -> ByteBuffer {
        return self.compressor.compress(&buffer)
    }
}