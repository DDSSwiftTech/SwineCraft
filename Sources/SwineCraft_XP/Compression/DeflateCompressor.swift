import SwiftZlib
import NIOCore

final class DeflateCompressor: Compressor {
    let method: CompressionMethod = .DEFLATE
    let compressionThreshold: Int = 256
    var adaptiveAllocator = AdaptiveRecvByteBufferAllocator(minimum: 256, initial: 256, maximum: 8 *  1024 * 1024)
    
    var strm = z_stream()

    required init() {
        deflateInit2_(&self.strm, 1, Z_DEFLATED, -MAX_WBITS, MAX_MEM_LEVEL, Z_DEFAULT_STRATEGY, zlibVersion(), Int32(MemoryLayout.size(ofValue: strm)))
    }

    func compress(_ inbuf: inout ByteBuffer) -> ByteBuffer {
        defer {deflateReset(&self.strm)}

        strm.avail_in = uInt(inbuf.readableBytes)

        return inbuf.withUnsafeMutableReadableBytes { inbufptr in
            var outbuf = ByteBufferAllocator().buffer(capacity: self.adaptiveAllocator.nextBufferSize() ?? 8 *  1024 * 1024)
            var retval = ZLIBError.OK

            strm.next_in = inbufptr.baseAddress?.assumingMemoryBound(to: Bytef.self)

            repeat {
                let tempBuf = UnsafeMutableBufferPointer<UInt8>.allocate(capacity: 65536); defer {tempBuf.deallocate()}

                strm.avail_out = uInt(tempBuf.count)
                strm.next_out = tempBuf.baseAddress

                retval = ZLIBError(rawValue: deflate(&self.strm, Z_SYNC_FLUSH)) ?? .VERSION

                outbuf.writeBytes(tempBuf)
            } while retval == .OK

            let bytesRecorded = self.adaptiveAllocator.record(actualReadBytes: outbuf.capacity)

            print("ADAPTIVE_BYTES_UPDATED \(bytesRecorded)")

            return dump(ByteBuffer(bytes: outbuf.getBytes(at: 0, length: Int(strm.total_out))!))
        }
    }
}