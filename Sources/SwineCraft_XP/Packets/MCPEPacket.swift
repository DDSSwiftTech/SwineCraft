import NIO


protocol MCPEPacket {
    var packetType: MCPEPacketType { get }

    init(from buffer: inout ByteBuffer) throws
    func encode() throws -> ByteBuffer
}

extension MCPEPacket {
    init(from buffer: inout ByteBuffer) throws {
        throw MCPE.Error.PacketDecode(nil)
    }

    func encode() throws -> ByteBuffer {
        throw MCPE.Error.PacketDecode(nil)
    }
}