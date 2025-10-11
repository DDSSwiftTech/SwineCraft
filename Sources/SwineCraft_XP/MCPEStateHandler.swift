import Foundation
import SwakNet

class MCPEStateHandler {
    typealias ProtocolVersion = Int32

    struct MCPEState {
        var source: RakNetAddress
        var protocolVersion: ProtocolVersion
        var activePlayer: Player? = nil
        var compressionMethod: CompressionMethod? = nil
        var clientThrottleEnabled: Bool = false
        var clientThrottleThreshold: UInt8 = 0
        var clientThrottleScalar: Float = 0
        var loginPacket: LoginPacket? = nil
        var clientCacheSupported: Bool = false
    }

    var activeGameStates: [RakNetAddress:MCPEState] = [:]

    func initializeState(source: RakNetAddress, version: ProtocolVersion) {
        self.activeGameStates[source] = MCPEState(source: source, protocolVersion: version)
    }

    func discardState(source: RakNetAddress) {
        self.activeGameStates[source] = nil
    }

    func stateActive(source: RakNetAddress) -> Bool {
        return self.activeGameStates.keys.contains(source)
    }

    func setLoginPacket(_ packet: LoginPacket, forSource source: RakNetAddress) {
        self.activeGameStates[source]?.loginPacket = packet
    }

    func setClientCacheSupported(_ supported: Bool, forSource source: RakNetAddress) {
        self.activeGameStates[source]?.clientCacheSupported = supported
    }

    func getClientCacheSupported(forSource source: RakNetAddress) -> Bool {
        return self.activeGameStates[source]?.clientCacheSupported ?? false
    }

    func setCompressionMethod(_ method: CompressionMethod, forSource source: RakNetAddress) {
        self.activeGameStates[source]?.compressionMethod = method
    }

    func getCompressionMethod(forSource source: RakNetAddress) -> CompressionMethod? {
        return self.activeGameStates[source]?.compressionMethod
    }

    init() {}
}