import NIO


extension RakNet {
    protocol Packet {
        var packetType: RakNet.PacketType { get }

        init(from buffer: inout ByteBuffer) throws
        func encode() throws -> ByteBuffer
    }
}

extension RakNet.Packet {
    init(from buffer: inout ByteBuffer) throws {
        throw RakNet.Error.PacketDecode(.INCOMPATIBLE_PROTOCOL)
    }

    func encode() throws -> ByteBuffer {
        throw RakNet.Error.PacketDecode(.INCOMPATIBLE_PROTOCOL)
    }
}