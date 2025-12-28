public struct NetworkBlockPosition: MCPEPacketEncodable {
    public let x: VarInt
    public let y: UnsignedVarInt
    public let z: VarInt
}