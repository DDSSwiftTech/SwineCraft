import NIO

struct OfflineConnectionResponse2: RakNetOfflinePacket {
    var packetType: RakNetPacketType = .OFFLINE_CONNECTION_RESPONSE_2
    let magic: UInt128
    let serverGUID: UInt64 = RakNetConfig.shared.GUID
    let clientAddress: RakNetAddress
    let mtuSize: UInt16 // assumption for now
    let requiresEncryption: UInt8 = 0
}