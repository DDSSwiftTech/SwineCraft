import NIO
import SwakNet

class MCPEHandler: ChannelInboundHandler, @unchecked Sendable {
    typealias InboundIn = ByteBuffer
    typealias OutboundOut = ByteBuffer
    
    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        print(self.unwrapInboundIn(data))
    }
}