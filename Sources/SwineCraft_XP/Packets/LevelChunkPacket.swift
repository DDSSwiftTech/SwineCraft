import NIOCore

struct LevelChunkPacket: MCPEPacket {
    let packetType: MCPEPacketType = .LEVEL_CHUNK

    private static let CLIENT_REQUEST_FULL_COLUMN_FAKE_COUNT = UInt32.max;

    let chunkPosition: Vec2
    let dimensionId: VarInt
    let subChunkCount: UnsignedVarInt = UnsignedVarInt(integerLiteral: Self.CLIENT_REQUEST_FULL_COLUMN_FAKE_COUNT)
    let useBlobHashes: Bool
    let serializedChunkData: String

    func encode(_ buf: inout ByteBuffer) throws {
        buf.writeInteger(self.packetType.rawValue)

    }
}