import NIO
import SwakNet
import SwiftSnappy
import SwiftNBT
import Foundation

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

    func userInboundEventTriggered(context: ChannelHandlerContext, event: Any) {
        let event = event as! RakNetEvent

        switch event {
            case .DISCONNECTED(let source, let reason):
                self.stateHandler.discardState(source: source)

                print("Disconnected: \(reason)")
        }
    }

    func errorCaught(context: ChannelHandlerContext, error: any Error) {print(error)}

    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        let inboundEnvelope = self.unwrapInboundIn(data)
        var buffer = inboundEnvelope.data
        let sourceAddress = RakNetAddress(from: inboundEnvelope.remoteAddress)!

        let old_buffer = buffer

        if self.stateHandler.getCompressionMethod(forSource: sourceAddress) != nil { // compression has been negotiated
            guard let compressionMethod = CompressionMethod(rawValue: Int16(buffer.readInteger()! as Int8)) else {
                print("bad compression method")

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
                    compressionThreshold: 256,
                    compressionMethod: .DEFLATE,
                    clientThrottleEnabled: false,
                    clientThrottleThreshold: 0,
                    clientThrottleScalar: 0
                )

                self.stateHandler.setCompressionMethod(.DEFLATE, forSource: sourceAddress)

                let data = try! responsePacket.encode()

                context.writeAndFlush(self.wrapOutboundOut(AddressedEnvelope(remoteAddress: inboundEnvelope.remoteAddress, data: ByteBuffer([0xfe] + VarInt(integerLiteral: Int32(data.readableBytes)).encode().readableBytesView + data.readableBytesView))), promise: nil)
            case .LOGIN:
                guard let packet = try? LoginPacket(from: &buffer) else {
                    return
                }

                print("RECEIVED LOGIN PACKET")

                self.stateHandler.setLoginPacket(packet, forSource: sourceAddress)

                let responsePacket = PlayStatusPacket(status: .LOGIN_SUCCESS)
                
                let data = self.compress(packet: responsePacket, sourceAddress: sourceAddress)

                context.writeAndFlush(self.wrapOutboundOut(AddressedEnvelope(remoteAddress: inboundEnvelope.remoteAddress, data: data)), promise: nil)
            case .CLIENT_CACHE_STATUS:
                guard let packet = try? ClientCacheStatusPacket(from: &buffer) else {
                    return
                }

                self.stateHandler.setClientCacheSupported(packet.cachingStatus, forSource: sourceAddress)

                print("RECEIVED CLIENT CACHE STATUS")

                let data = self.compress(packet: packet, sourceAddress: sourceAddress)

                context.writeAndFlush(self.wrapOutboundOut(AddressedEnvelope(remoteAddress: inboundEnvelope.remoteAddress, data: data)), promise: nil)

                print(Config.shared["worldFolder", default: "worlds"] as String?)

                let startGamePacket = StartGamePacket(
                    playerEntityID: .init(integerLiteral: .random(in: 0..<50000000)),
                    runtimeEntityID: .init(integerLiteral: .random(in: 0..<50000000)),
                    playerGamemode: 0,
                    position: Vec3(x: 0, y: 0, z: 0),
                    rotation: Vec2(x: 0, y: 0),
                    settings: LevelSettings(try! NBTFile(fromFile: URL(string: "")!).fileCompound) ,
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

                let startGameData = compress(packet: startGamePacket, sourceAddress: sourceAddress)

                context.writeAndFlush(self.wrapOutboundOut(AddressedEnvelope(remoteAddress: inboundEnvelope.remoteAddress, data: startGameData)), promise: nil)
            case nil:
                print("UNKNOWN PACKET TYPE \(old_buffer)")
            default: 
                print("UNIMEPLEMENTED PACKET TYPE \(old_buffer)")
        }
    }

    func compress(packet: MCPEPacket, sourceAddress: RakNetAddress) -> ByteBuffer {
        var basebuf = ByteBuffer([0xFE])
        var packetBuf = try! packet.encode()
        var packetbufWithLength = VarInt(integerLiteral: Int32(packetBuf.readableBytes)).encode()
        packetbufWithLength.writeBuffer(&packetBuf)

        if var method = self.stateHandler.getCompressionMethod(forSource: sourceAddress) {
            var compressor = self.registeredCompressors[method]!

            if packetbufWithLength.readableBytes < compressor.compressionThreshold {
                method = .None // never compress if below threshold
                compressor = self.registeredCompressors[.None]!
            }

            print("COMPRESSING WITH \(method)")

            basebuf.writeBytes([UInt8(method.rawValue & 0xFF)])

            var compressedBuf = compressor.compress(&packetbufWithLength)

            basebuf.writeBuffer(&compressedBuf)
        }

        return basebuf
    }
}