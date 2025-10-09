import NIO

struct OfflineConnectionResponse1: RakNetOfflinePacket {
    let packetType: RakNetPacketType = .OFFLINE_CONNECTION_RESPONSE_1
    let magic: UInt128 // 16 bytes
    let serverGUID: UInt64 = RakNetConfig.shared.GUID
    let serverHasSecurity: Bool
    let mtuSize: UInt16

    init(magic: UInt128, serverHasSecurity: Bool, mtu: UInt16) {
        self.magic = magic
        self.serverHasSecurity = serverHasSecurity
        self.mtuSize = mtu
    }

    init(from buffer: inout ByteBuffer) throws {
        magic = buffer.readMagic() ?? 0
        serverHasSecurity = (buffer.readInteger()! as UInt8) == 1
        self.mtuSize = buffer.readInteger()!
    }
}