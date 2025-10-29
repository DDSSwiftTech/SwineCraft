import NIOCore

struct Vec2: MCPEPacketEncodable {
    let x: Float
    let y: Float

    func encode(_ buf: inout ByteBuffer) throws {
        buf.writeInteger(x.bitPattern)
        buf.writeInteger(y.bitPattern)
    }
}