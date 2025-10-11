import NIOCore

final class NoneCompressor: Compressor {
    var method: CompressionMethod = .None

    var compressionThreshold: Int = 0

    func compress(_ inbuf: inout NIOCore.ByteBuffer) -> NIOCore.ByteBuffer {
        return inbuf
    }
}