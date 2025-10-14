import NIOCore

extension ByteBuffer {
    mutating func writeNBT(_ node: NBTNode) {
        var buf = node.encodeNBT()
        
        self.writeBuffer(&buf)
    }
}