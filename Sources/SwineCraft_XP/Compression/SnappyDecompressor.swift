// import SwiftSnappy
// import NIOCore

// class SnappyDecompressor {
//     var adaptiveAllocator: AdaptiveRecvByteBufferAllocator

//     init(bufSize: Int) {
//         self.adaptiveAllocator = AdaptiveRecvByteBufferAllocator(minimum: bufSize, initial: bufSize, maximum: 8 *  1024 * 1024)
//     }

//     func decompress(_ inbuf: inout ByteBuffer) -> ByteBuffer {
//         strm.avail_in = uInt(inbuf.readableBytes)

//         return inbuf.withUnsafeMutableReadableBytes { inbufptr in
//             var outbuf = ByteBufferAllocator().buffer(capacity: self.adaptiveAllocator.nextBufferSize() ?? 256)
//             var retval = ZLIBError.OK

//             strm.next_in = inbufptr.baseAddress?.assumingMemoryBound(to: Bytef.self)

//             repeat {

//                 let tempBuf = UnsafeMutableBufferPointer<UInt8>.allocate(capacity: 65536); defer {tempBuf.deallocate()}

//                 tempBuf.initialize(repeating: 0)

//                 strm.avail_out = uInt(tempBuf.count)

//                 strm.next_out = tempBuf.baseAddress

//                 retval = ZLIBError(rawValue: inflate(&self.strm, Z_SYNC_FLUSH))!

//                 outbuf.writeBytes(tempBuf)
//             } while retval == .OK

//             return outbuf
//         }
//     }
// }