import NIOCore

extension ByteBuffer {
    mutating func writeNBT(_ node: any NBTEncodable) {
        node.encodeFull(&self)
    }
}