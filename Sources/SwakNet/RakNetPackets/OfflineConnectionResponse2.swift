import NIO

struct OfflineConnectionResponse2: RakNet.OfflinePacket {
    var packetType: RakNet.PacketType = .OFFLINE_CONNECTION_RESPONSE_2
    let magic: UInt128
    let serverGUID: UInt64 = RakNet.Config.shared.GUID
    let clientAddress: RakNet.Address
    let mtuSize: UInt16 // assumption for now
    let requiresEncryption: UInt8 = 0

    func encode() throws -> ByteBuffer {
        var buffer = ByteBuffer()

        buffer.writeInteger(packetType.rawValue)
        buffer.writeInteger(magic)
        buffer.writeInteger(serverGUID)
        var addrBuf = clientAddress.encode()
        buffer.writeBuffer(&addrBuf)
        buffer.writeInteger(mtuSize)
        buffer.writeInteger(requiresEncryption)

        return buffer
    }
}