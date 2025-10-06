import Foundation
import SwakNet

class MCPEStateHandler {
    typealias ProtocolVersion = Int32

    struct MCPEState {
        var source: RakNet.Address
        var protocolVersion: ProtocolVersion
        var activePlayer: Player? = nil
        var compressionThreshold: Int16 = 0
        var compressionMethod: CompressionMethod = .Snappy
        var clientThrottleEnabled: Bool = false
        var clientThrottleThreshold: UInt8 = 0
        var clientThrottleScalar: Float = 0
        var loginPacket: LoginPacket? = nil
    }

    var activeGameStates: [RakNet.Address:MCPEState] = [:]

    func initializeState(source: RakNet.Address, version: ProtocolVersion) {
        self.activeGameStates[source] = MCPEState(source: source, protocolVersion: version)
    }

    func discardState(source: RakNet.Address) {
        if self.activeGameStates.keys.contains(source) {
            self.activeGameStates.removeValue(forKey: source)
        }
    }

    func stateActive(source: RakNet.Address) -> Bool {
        return self.activeGameStates.keys.contains(source)
    }

    func setLoginPacket(_ packet: LoginPacket, forSource source: RakNet.Address) {
        self.activeGameStates[source]?.loginPacket = packet
    }

    init() {}
}