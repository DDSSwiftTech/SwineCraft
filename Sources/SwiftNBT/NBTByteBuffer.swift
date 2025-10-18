import NIOCore
import Foundation

extension ByteBuffer {
    init(_ node: any NBTEncodable) throws {
        self.init()

        try node.encodeFull(&self)
    }

    mutating func writeNBT(_ node: any NBTEncodable) throws {
        try node.encodeFull(&self)
    }
}