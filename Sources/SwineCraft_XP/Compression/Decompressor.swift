import NIOCore

protocol Decompressor {
    var method: CompressionMethod { get }

    init()
    func decompress(_ inbuf: inout ByteBuffer) -> ByteBuffer
}