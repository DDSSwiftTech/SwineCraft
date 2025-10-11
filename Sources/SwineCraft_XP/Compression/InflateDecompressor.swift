import SwiftZlib
import NIOCore

final class InflateDecompressor: Decompressor {
    var method: CompressionMethod = .DEFLATE
    var adaptiveAllocator = AdaptiveRecvByteBufferAllocator(minimum: 256, initial: 256, maximum: 8 * 1024 * 1024)
    
    var strm = z_stream()

    required init() {
        inflateInit2_(&self.strm, -MAX_WBITS, zlibVersion(), Int32(MemoryLayout.size(ofValue: strm)))
    }

    func decompress(_ inbuf: inout ByteBuffer) -> ByteBuffer {
        defer {inflateReset2(&self.strm, -MAX_WBITS)}

        strm.avail_in = uInt(inbuf.readableBytes)

        return inbuf.withUnsafeMutableReadableBytes { inbufptr in
            var outbuf = ByteBufferAllocator().buffer(capacity: self.adaptiveAllocator.nextBufferSize()!)
            var retval = ZLIBError.OK

            print("ADAPTIVE_OUTBUF_CAPACITY: \(outbuf.capacity)")

            strm.next_in = inbufptr.baseAddress?.assumingMemoryBound(to: Bytef.self)

            repeat {
                let tempBuf = UnsafeMutableBufferPointer<UInt8>.allocate(capacity: 65536); defer {tempBuf.deallocate()}

                strm.avail_out = uInt(tempBuf.count)
                strm.next_out = tempBuf.baseAddress

                retval = ZLIBError(rawValue: inflate(&self.strm, Z_SYNC_FLUSH)) ?? .VERSION

                outbuf.writeBytes(tempBuf)
            } while retval == .OK

            let bytesRecorded = self.adaptiveAllocator.record(actualReadBytes: outbuf.capacity)

            print("ADAPTIVE_BYTES_UPDATED \(bytesRecorded)")

            return outbuf
        }
    }
}