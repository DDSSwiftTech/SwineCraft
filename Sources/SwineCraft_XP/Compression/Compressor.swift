import NIOCore

protocol Compressor {
    init(bufSize: Int)
    func compress(_ inbuf: inout ByteBuffer) -> ByteBuffer
}