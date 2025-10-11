import NIOCore

protocol Decompressor {
    init()
    func decompress(_ inbuf: inout ByteBuffer) -> ByteBuffer
}