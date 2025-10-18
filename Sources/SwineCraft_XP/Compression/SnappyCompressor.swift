import SwiftSnappy
import NIOCore

class SnappyCompressor: Compressor {
    var method: CompressionMethod = .Snappy
    var compressionThreshold: Int = 256
    var adaptiveAllocator = AdaptiveRecvByteBufferAllocator(minimum: 256, initial: 256, maximum: 8 *  1024 * 1024)

    required init() {}

    func compress(_ inbuf: inout ByteBuffer) -> ByteBuffer {
        var outputLength = snappy_max_compressed_length(inbuf.readableBytes)
        var resultBuf = ByteBufferAllocator().buffer(capacity: outputLength)
        let readableBytesView = Array<UInt8>(inbuf.readableBytesView)

        let bytesRead = resultBuf.writeWithUnsafeMutableBytes(minimumWritableBytes: outputLength) { outptr in
            let _ = snappy_compress(readableBytesView, inbuf.readableBytes, outptr.baseAddress, &outputLength)

            return outputLength
        }
        
        return resultBuf
    }
}