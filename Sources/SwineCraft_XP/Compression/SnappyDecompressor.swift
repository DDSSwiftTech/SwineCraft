import SwiftSnappy
import NIOCore

class SnappyDecompressor: Decompressor {
    var method: CompressionMethod = .Snappy
    var adaptiveAllocator = AdaptiveRecvByteBufferAllocator(minimum: 256, initial: 256, maximum: 8 *  1024 * 1024)

    required init() {}

    func decompress(_ inbuf: inout ByteBuffer) -> ByteBuffer {
        var resultBuf = ByteBuffer()

        inbuf.readWithUnsafeReadableBytes { inbufptr in
            var uncompressedLength = 0

            snappy_uncompressed_length(inbufptr.baseAddress, inbufptr.count, &uncompressedLength)

            let outbuf = UnsafeMutableBufferPointer<UInt8>.allocate(capacity: uncompressedLength)

            defer {outbuf.deallocate()}

            var outputLength = uncompressedLength

            let _ = snappy_uncompress(inbufptr.baseAddress, inbufptr.count, outbuf.baseAddress, &outputLength)

            resultBuf.writeBytes(outbuf)

            return outputLength
        }
        
        return resultBuf

    }
}