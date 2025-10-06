import NIO

protocol RakNetPacket {
    var packetType: RakNetPacketType { get }

    init(from buffer: inout ByteBuffer) throws
    func encode() throws -> ByteBuffer
}

extension RakNetPacket {
    init(from buffer: inout ByteBuffer) throws {
        throw RakNetError.PacketDecode(.INCOMPATIBLE_PROTOCOL)
    }

    func encode() throws -> ByteBuffer {
        throw RakNetError.PacketDecode(.INCOMPATIBLE_PROTOCOL)
    }
}