import NIOCore

struct NetworkSettingsPacket: MCPEPacket {
    var packetType: MCPEPacketType = .NETWORK_SETTINGS

    let compressEverything: Bool
    let compressionThreshold: UInt16
    let compressionMethod: CompressionMethod
    let clientThrottleEnabled: Bool
    let clientThrottleThreshold: UInt8
    let clientThrottleScalar: Float
}