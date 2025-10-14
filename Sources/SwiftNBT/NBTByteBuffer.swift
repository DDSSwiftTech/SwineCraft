import NIOCore

extension ByteBuffer {
    init(_ node: any NBTEncodable) {
        self.init()

        node.encodeFull(&self)
    }

    mutating func writeNBT(_ node: any NBTEncodable) {
        node.encodeFull(&self)
    }
}