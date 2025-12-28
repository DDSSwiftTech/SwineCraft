import NIO
import SwakNet
import SwiftSnappy
import SwiftNBT
import Foundation
import Logging

class MCPEHandler: ChannelInboundHandler, @unchecked Sendable {
    typealias InboundIn = AddressedEnvelope<ByteBuffer>
    typealias OutboundOut = AddressedEnvelope<ByteBuffer>

    let stateHandler = MCPEStateHandler()
    let registeredCompressors: [CompressionMethod: Compressor] = [
        .DEFLATE: DeflateCompressor(),
        .Snappy: SnappyCompressor(),
        .None: NoneCompressor()
    ]
    let registeredDecompressors: [CompressionMethod: Decompressor] = [
        .DEFLATE: InflateDecompressor(),
        .Snappy: SnappyDecompressor(),
        .None: NoneDecompressor()
    ]

    private let logger = Logger(autoLogLevelWithLabel: "MCPEHandler")

    func userInboundEventTriggered(context: ChannelHandlerContext, event: Any) {
        let event = event as! RakNetEvent

        switch event {
            case .DISCONNECTED(let source, let reason):
                self.stateHandler.discardState(source: source)

                logger.info("Disconnected: \(reason)")
        }
    }

    func errorCaught(context: ChannelHandlerContext, error: any Error) {logger.error("\(error)")}

    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        let inboundEnvelope = self.unwrapInboundIn(data)
        var buffer = inboundEnvelope.data
        let sourceAddress = RakNetAddress(from: inboundEnvelope.remoteAddress)!

        let old_buffer = buffer

        if self.stateHandler.getCompressionMethod(forSource: sourceAddress) != nil { // compression has been negotiated
            guard let compressionMethod = CompressionMethod(rawValue: Int16(buffer.readInteger()! as Int8)) else {
                logger.error("bad compression method")

                return
            }

            buffer = self.registeredDecompressors[compressionMethod]!.decompress(&buffer)
        }

        let bufferLength = buffer.readVarInt()

        buffer = ByteBuffer(bytes: buffer.readBytes(length: Int(bufferLength.backingInt))!)

        guard let rawPacketType: UInt8 = buffer.readInteger() else {
            return
        }

        switch MCPEPacketType(rawValue: rawPacketType) {
            case .REQUEST_NETWORK_SETTINGS:
                guard let packet = try? RequestNetworkSettingsPacket(from: &buffer) else {
                    return
                }

                self.stateHandler.initializeState(source: sourceAddress, version: packet.protocolVersion)

                let responsePacket = NetworkSettingsPacket(
                    compressEverything: true,
                    compressionThreshold: 256,
                    compressionMethod: .DEFLATE,
                    clientThrottleEnabled: false,
                    clientThrottleThreshold: 0,
                    clientThrottleScalar: 0
                )

                self.stateHandler.setCompressionMethod(.DEFLATE, forSource: sourceAddress)
                
                var packetBuf = ByteBuffer()
                try? responsePacket.encode(&packetBuf)

                var resultBuf = ByteBufferAllocator().buffer(capacity: 5)

                resultBuf.writeBytes([0xFE])
                try? VarInt(integerLiteral: Int32(packetBuf.readableBytes)).encode(&resultBuf)
                resultBuf.writeBuffer(&packetBuf)

                logger.debug("SENDING NETWORK SETTINGS")

                context.writeAndFlush(self.wrapOutboundOut(AddressedEnvelope(remoteAddress: inboundEnvelope.remoteAddress, data: resultBuf)), promise: nil)
            case .LOGIN:
                guard let packet = try? LoginPacket(from: &buffer) else {
                    return
                }

                logger.debug("RECEIVED LOGIN PACKET")

                self.stateHandler.setLoginPacket(packet, forSource: sourceAddress)

                let responsePacket = PlayStatusPacket(status: .LOGIN_SUCCESS)

                var dataBuf = ByteBuffer()
                
                self.compress(packet: responsePacket, sourceAddress: sourceAddress, toBuffer: &dataBuf)

                context.writeAndFlush(self.wrapOutboundOut(AddressedEnvelope(remoteAddress: inboundEnvelope.remoteAddress, data: dataBuf)), promise: nil)
            case .CLIENT_CACHE_STATUS:
                guard let packet = try? ClientCacheStatusPacket(from: &buffer) else {
                    return
                }

                self.stateHandler.setClientCacheSupported(packet.cachingStatus, forSource: sourceAddress)

                self.logger.debug("RECEIVED CLIENT CACHE STATUS")

                var data = ByteBuffer()

                self.compress(packet: packet, sourceAddress: sourceAddress, toBuffer: &data)

                context.writeAndFlush(self.wrapOutboundOut(AddressedEnvelope(remoteAddress: inboundEnvelope.remoteAddress, data: data)), promise: nil)

                let resourcePackInfos = ResourcePacksInfoPacket()

                var resourcePackInfosBuf = ByteBuffer()

                compress(packet: resourcePackInfos, sourceAddress: sourceAddress, toBuffer: &resourcePackInfosBuf)

                context.writeAndFlush(self.wrapOutboundOut(AddressedEnvelope(remoteAddress: inboundEnvelope.remoteAddress, data: resourcePackInfosBuf)), promise: nil)
            case .RESOURCE_PACK_CLIENT_RESPONSE:
                guard let packet = try? ResourcePackClientResponsePacket(from: &buffer) else {
                    return
                }

                let startGamePacket = StartGamePacket(
                    playerEntityID: .init(integerLiteral: .random(in: 0..<50000000)),
                    runtimeEntityID: .init(integerLiteral: .random(in: 0..<50000000)),
                    playerGamemode: 0,
                    position: Vec3(x: 0, y: 0, z: 0),
                    rotation: Vec2(x: 0, y: 0),
                    settings: LevelSettings(try! NBTFile(fromFile: URL(string: "/home/david/swift_projects/SwineCraft_XP/Tests/SwineCraft_XPTests/Resources/level.dat")!).fileCompound) ,
                    levelID: "300",
                    levelName: "Default World",
                    templateContentIdentity: "None",
                    isTrial: false,
                    movementSettings: SyncedPlayerMovementSettings(
                        rewindHistorySize: 0,
                        serverAuthoritativeBlockBreaking: true
                    ),
                    levelCurrentTime: 0,
                    enchantmentSeed: VarInt(integerLiteral: .random(in: Int32.min..<Int32.max)),
                    blockProperties: [],
                    multiplayerCorrelationID: "\(UInt64.random(in: UInt64.min..<UInt64.max))",
                    enableItemStackNetManager: true,
                    serverVersion: "\(RakNetProtocolInfo.VERSION)",
                    playerPropertyData: NBTCompound(),
                    serverBlockTypeRegistryChecksum: UInt64.random(in: UInt64.min..<UInt64.max),
                    worldTemplateID: UUID(),
                    serverEnabledClientSideGeneration: false,
                    blockTypesAreHashes: false,
                    networkPermissions: NetworkPermissions(
                        serverAuthSoundEnabled: true
                    )
                )

                var startGameBuf = ByteBuffer()

                compress(packet: startGamePacket, sourceAddress: sourceAddress, toBuffer: &startGameBuf)

                context.writeAndFlush(self.wrapOutboundOut(AddressedEnvelope(remoteAddress: inboundEnvelope.remoteAddress, data: startGameBuf)), promise: nil)

                let creativeContentPacket = CreativeContentPacket()

                var creativeContentBuf = ByteBuffer()
                
                compress(packet: creativeContentPacket, sourceAddress: sourceAddress, toBuffer: &creativeContentBuf)

                context.writeAndFlush(self.wrapOutboundOut(AddressedEnvelope(remoteAddress: inboundEnvelope.remoteAddress, data: creativeContentBuf)), promise: nil)

                let biomeDefinitionListPacket = BiomeDefinitionListPacket()

                var biomeDefinitionListBuf = ByteBuffer()
                
                compress(packet: biomeDefinitionListPacket, sourceAddress: sourceAddress, toBuffer: &biomeDefinitionListBuf)

                context.writeAndFlush(self.wrapOutboundOut(AddressedEnvelope(remoteAddress: inboundEnvelope.remoteAddress, data: biomeDefinitionListBuf)), promise: nil)

                let levelChunkPacket = LevelChunkPacket(
                    chunkPosition: Vec2(x: 50, y: 50),
                    dimensionId: 0,
                    useBlobHashes: false,
                    serializedChunkData: ""
                )

                var levelChunkBuf = ByteBuffer()
                
                compress(packet: levelChunkPacket, sourceAddress: sourceAddress, toBuffer: &levelChunkBuf)

                context.writeAndFlush(self.wrapOutboundOut(AddressedEnvelope(remoteAddress: inboundEnvelope.remoteAddress, data: levelChunkBuf)), promise: nil)
            case nil:
                self.logger.error("UNKNOWN PACKET TYPE \(old_buffer)")
            default: 
                self.logger.error("UNIMEPLEMENTED PACKET TYPE \(old_buffer)")
        }
    }

    func compress(packet: MCPEPacket, sourceAddress: RakNetAddress, toBuffer buf: inout ByteBuffer) {
        buf.writeBytes([0xFE])
        
        var packetBuf = ByteBuffer()
        try? packet.encode(&packetBuf)

        var packetBufWithLength = ByteBuffer()
        try? VarInt(integerLiteral: Int32(packetBuf.readableBytes)).encode(&packetBufWithLength)
        packetBufWithLength.writeBuffer(&packetBuf)

        if var method = self.stateHandler.getCompressionMethod(forSource: sourceAddress) {
            var compressor = self.registeredCompressors[method]!

            if packetBufWithLength.readableBytes < compressor.compressionThreshold {
                method = .None // never compress if below threshold
                compressor = self.registeredCompressors[.None]!
            }

            logger.debug("COMPRESSING PACKET \(packet) WITH \(method)")

            buf.writeBytes([UInt8(method.rawValue & 0xFF)])

            var compressedBuf = compressor.compress(&packetBufWithLength)

            buf.writeBuffer(&compressedBuf)
        }
    }
}