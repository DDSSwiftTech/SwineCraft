import SwiftSnappy
import NIOCore

class SnappyCompressor: Compressor {
    var method: CompressionMethod = .Snappy
    var compressionThreshold: Int = 256
    var adaptiveAllocator = AdaptiveRecvByteBufferAllocator(minimum: 256, initial: 256, maximum: 8 *  1024 * 1024)

    required init() {}

    func compress(_ inbuf: inout ByteBuffer) -> ByteBuffer {
        let outbuf = UnsafeMutableBufferPointer<UInt8>.allocate(capacity: snappy_max_compressed_length(inbuf.readableBytes))

        defer {outbuf.deallocate()}

        inbuf.readWithUnsafeReadableBytes { inbufptr in
            var outputLength = snappy_max_compressed_length(inbufptr.count)

            let _ = snappy_compress(inbufptr.baseAddress, inbufptr.count, outbuf.baseAddress, &outputLength)

            return outputLength
        }

        var resultBuf = ByteBuffer()

        resultBuf.writeBytes(outbuf)
        
        return resultBuf
    }
}