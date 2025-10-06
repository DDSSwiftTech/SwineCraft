import NIO

class RakNetOutboundHandler: ChannelOutboundHandler, @unchecked Sendable {
    typealias OutboundIn = AddressedEnvelope<ByteBuffer>
    typealias OutboundOut = AddressedEnvelope<ByteBuffer>

    func write(context: ChannelHandlerContext, data: NIOAny, promise: EventLoopPromise<Void>?) {
        let inboundEnvelope = self.unwrapOutboundIn(data)

        context.eventLoop.makeFutureWithTask {
            await RakNetStateHandler.shared.encapsulate(buffers: [inboundEnvelope.data], connectionID: RakNetAddress(from: inboundEnvelope.remoteAddress)!)
        }.whenComplete { result in
            context.write(self.wrapOutboundOut(AddressedEnvelope(remoteAddress: inboundEnvelope.remoteAddress, data: try! result.get().encode())), promise: nil)
        }
    }
}