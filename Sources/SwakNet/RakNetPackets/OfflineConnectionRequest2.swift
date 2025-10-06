import NIO

struct OfflineConnectionRequest2: RakNetOfflinePacket {
    var packetType: RakNetPacketType = .OFFLINE_CONNECTION_REQUEST_2
    let magic: UInt128
    let serverAddressType: UInt8 // assuming v4 for now
    let serverAddress: UInt32
    let serverAddressPort: UInt16
    let mtuSize: UInt16
    let clientGUID: UInt16

    init(from buffer: ByteBuffer) throws {
        var buffer = buffer

        guard let magic: UInt128 = buffer.readInteger(),
        let serverAddressType: UInt8 = buffer.readInteger(), serverAddressType == 4 || serverAddressType == 6,
        let serverAddress: UInt32 = buffer.readInteger(),
        let serverAddressPort: UInt16 = buffer.readInteger(),
        let mtuSize: UInt16 = buffer.readInteger(),
        let clientGUID: UInt16 = buffer.readInteger() else {
            throw RakNetError.PacketDecode(packetType)
        }

        self.magic = magic
        self.serverAddressType = serverAddressType
        self.serverAddress = serverAddress
        self.serverAddressPort = serverAddressPort
        self.mtuSize = mtuSize
        self.clientGUID = clientGUID
    }
}