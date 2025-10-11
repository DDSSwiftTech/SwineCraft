import SwiftZlib
import NIOCore

class DeflateCompressor {
    var adaptiveAllocator: AdaptiveRecvByteBufferAllocator
    
    var strm = z_stream()

    init(bufSize: Int) {
        self.adaptiveAllocator = AdaptiveRecvByteBufferAllocator(minimum: bufSize, initial: bufSize, maximum: 8 *  1024 * 1024)

        deflateInit2_(&self.strm, 1, Z_DEFLATED, -MAX_WBITS, MAX_MEM_LEVEL, Z_DEFAULT_STRATEGY, zlibVersion(), Int32(MemoryLayout.size(ofValue: strm)))
    }

    func compress(_ inbuf: inout ByteBuffer) -> ByteBuffer {
        strm.avail_in = uInt(inbuf.readableBytes)

        return inbuf.withUnsafeMutableReadableBytes { inbufptr in
            var outbuf = ByteBufferAllocator().buffer(capacity: self.adaptiveAllocator.nextBufferSize() ?? 8 *  1024 * 1024)
            var retval = ZLIBError.OK

            strm.next_in = inbufptr.baseAddress?.assumingMemoryBound(to: Bytef.self)

            repeat {
                let tempBuf = UnsafeMutableBufferPointer<UInt8>.allocate(capacity: 65536); defer {tempBuf.deallocate()}

                strm.avail_out = uInt(tempBuf.count)

                strm.next_out = tempBuf.baseAddress

                retval = ZLIBError(rawValue: deflate(&self.strm, Z_SYNC_FLUSH))!

                outbuf.writeBytes(tempBuf)
            } while retval == .OK

            return outbuf
        }
    }
}