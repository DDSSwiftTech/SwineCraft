import NIO

final public class SwakNetServer {
    private let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 20)

    public init() {}

    public func listen(onIP ip: String, andPort port: UInt16, serverIDString: String, dataHandler: any ChannelInboundHandler & Sendable) async throws {
        let bootstrap = DatagramBootstrap(group: eventLoopGroup)
        
        .channelInitializer { chan in
            chan.eventLoop.makeCompletedFuture {
                let handler = RakNetHandler(
                    SERVER_ID_STRING: serverIDString
                )
                
                try chan.pipeline.syncOperations.addHandlers([
                    handler,
                    RakNetOutboundHandler(),
                    dataHandler
                ])
            }
        }

        let channel = try await bootstrap.bind(host: ip, port: Int(port)).get()

        try await channel.closeFuture.get()
    }

    deinit {
        try? self.eventLoopGroup.syncShutdownGracefully()
    }
}