import NIOCore

protocol Decompressor {
    init(bufSize: Int)
    func decompress(_ inbuf: inout ByteBuffer) -> ByteBuffer
}