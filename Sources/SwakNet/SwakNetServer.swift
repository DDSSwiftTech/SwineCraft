import NIO

final public class SwakNetServer {
    private let group = MultiThreadedEventLoopGroup(numberOfThreads: 20)

    public init() {}

    public func listen(onIP ip: String, andPort port: UInt16, serverIDString: String, dataHandler: any ChannelInboundHandler & Sendable) async throws {
        let bootstrap = DatagramBootstrap(group: group)
        
        .channelInitializer { chan in
            chan.eventLoop.makeCompletedFuture {
                try chan.pipeline.syncOperations.addHandlers([
                    RakNet.Handler(
                        SERVER_ID_STRING: serverIDString
                    ),
                    dataHandler
                ])

            }
        }

        let channel = try await bootstrap.bind(host: ip, port: Int(port)).get()

        try await channel.closeFuture.get()
    }

    deinit {
        try? self.group.syncShutdownGracefully()
    }
}