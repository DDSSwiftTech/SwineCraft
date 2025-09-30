extension RakNet {
    protocol OfflinePacket: RakNet.Packet {
        var magic: UInt128 { get }
    }
}