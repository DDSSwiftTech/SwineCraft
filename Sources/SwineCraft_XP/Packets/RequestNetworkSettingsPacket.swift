import NIOCore

struct RequestNetworkSettingsPacket: MCPEPacket {
    var packetType: MCPEPacketType = .REQUEST_NETWORK_SETTINGS

    let protocolVersion: Int32

    init(from buffer: inout ByteBuffer) throws {
        let _ = buffer.readBytes(length: 1) // There's a byte here, 0x01. Not sure what it is yet
        
        self.protocolVersion = buffer.readInteger()!
    }
}