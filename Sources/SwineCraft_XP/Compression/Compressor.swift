import NIOCore

protocol Compressor {
    var method: CompressionMethod { get }
    var compressionThreshold: Int { get }

    init()
    func compress(_ inbuf: inout ByteBuffer) -> ByteBuffer
}