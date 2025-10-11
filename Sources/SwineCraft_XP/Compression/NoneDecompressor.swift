import NIOCore

final class NoneDecompressor: Decompressor {
    var method: CompressionMethod = .None

    func decompress(_ inbuf: inout NIOCore.ByteBuffer) -> NIOCore.ByteBuffer {
        return inbuf
    }
}