import NIOCore

protocol Compressor {
    init()
    func compress(_ inbuf: inout ByteBuffer) -> ByteBuffer
}