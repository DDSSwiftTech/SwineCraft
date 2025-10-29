import NIOCore

protocol MCPEPacketEncodable {
    func encode(_ buf: inout ByteBuffer) throws
}

protocol MCPEPacketDecodable {
    init(from buffer: inout ByteBuffer) throws
}

typealias MCPEPacketCodable = MCPEPacketEncodable & MCPEPacketDecodable