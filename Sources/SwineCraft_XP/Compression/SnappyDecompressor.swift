import SwiftSnappy
import NIOCore

class SnappyDecompressor: Decompressor {
    var method: CompressionMethod = .Snappy
    var adaptiveAllocator = AdaptiveRecvByteBufferAllocator(minimum: 256, initial: 256, maximum: 8 *  1024 * 1024)

    required init() {}

    func decompress(_ inbuf: inout ByteBuffer) -> ByteBuffer {
        let readableBytesView = Array<UInt8>(inbuf.readableBytesView)
        var uncompressedLength = 0

        snappy_uncompressed_length(readableBytesView, readableBytesView.count, &uncompressedLength)

        var resultBuf = ByteBufferAllocator().buffer(capacity: uncompressedLength)

        let _ = resultBuf.writeWithUnsafeMutableBytes(minimumWritableBytes: uncompressedLength) { outptr in
            let _ = snappy_uncompress(readableBytesView, readableBytesView.count, outptr.baseAddress, &uncompressedLength)

            return uncompressedLength
        }
        
        return resultBuf
    }
}