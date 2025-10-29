import NIOCore

struct Vec3: MCPEPacketEncodable {
    let x: Float
    let y: Float
    let z: Float

    func encode(_ buf: inout ByteBuffer) throws {
        buf.writeInteger(x.bitPattern)
        buf.writeInteger(y.bitPattern)
        buf.writeInteger(z.bitPattern)
    }
}