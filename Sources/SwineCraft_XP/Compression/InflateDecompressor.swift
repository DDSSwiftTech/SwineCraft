import SwiftZlib
import NIOCore

class InflateDecompressor {
    var adaptiveAllocator: AdaptiveRecvByteBufferAllocator
    
    var strm = z_stream()

    init(bufSize: Int) {
        self.adaptiveAllocator = AdaptiveRecvByteBufferAllocator(minimum: bufSize, initial: bufSize, maximum: 8 *  1024 * 1024)

        inflateInit2_(&self.strm, -MAX_WBITS, zlibVersion(), Int32(MemoryLayout.size(ofValue: strm)))
    }

    func decompress(_ inbuf: inout ByteBuffer) -> ByteBuffer {
        strm.avail_in = uInt(inbuf.readableBytes)

        print("begin")

        return inbuf.withUnsafeMutableReadableBytes { inbufptr in
            var outbuf = ByteBufferAllocator().buffer(capacity: self.adaptiveAllocator.nextBufferSize() ?? 256)
            var retval = ZLIBError.OK

            strm.next_in = inbufptr.baseAddress?.assumingMemoryBound(to: Bytef.self)

            repeat {
                let tempBuf = UnsafeMutableBufferPointer<UInt8>.allocate(capacity: 65536); defer {tempBuf.deallocate()}

                strm.avail_out = uInt(tempBuf.count)

                strm.next_out = tempBuf.baseAddress

                retval = ZLIBError(rawValue: inflate(&self.strm, Z_SYNC_FLUSH))!

                outbuf.writeBytes(tempBuf)
            } while retval == .OK

            print("end")

            return outbuf
        }
    }
}