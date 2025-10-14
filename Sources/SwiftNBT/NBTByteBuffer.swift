import NIOCore

extension ByteBuffer {
    init(_ node: any NBTEncodable) {
        self.init()

        node.encodeBody(&self)
    }
    
    mutating func writeNBT(_ node: any NBTEncodable) {
        node.encodeFull(&self)
    }
}