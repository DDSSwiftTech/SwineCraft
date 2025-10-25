import NIO

struct OfflineConnectionResponse1: RakNetOfflinePacket {
    let packetType: RakNetPacketType = .OFFLINE_CONNECTION_RESPONSE_1
    let magic: UInt128 // 16 bytes
    let serverGUID: UInt64 = RakNetConfig.shared.GUID
    let serverHasSecurity: Bool
    let mtuSize: UInt16
}