import NIOCore
import NIOExtras
import SwiftZlib

struct GamePacket {
    private let packetData: ByteBuffer

    init(_ buffer: ByteBuffer) {
        self.packetData = buffer
    }

    init(compressed: inout ByteBuffer) {
        var destination = ByteBuffer()
        var capacity: Int = 0
        let srcCapacity: Int = compressed.readableBytes

        let _ = destination.withUnsafeMutableWritableBytes { destBuf in
            let _ = compressed.withUnsafeMutableWritableBytes { srcBuf in
                uncompress(
                    destBuf.baseAddress,
                    &capacity,
                    srcBuf.baseAddress,
                    uLong(srcCapacity))
            }

        }

        self.packetData = destination
    }

    public func getBuffer() -> ByteBuffer {
        return self.packetData
    }
}