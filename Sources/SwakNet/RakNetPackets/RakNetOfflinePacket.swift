
protocol RakNetOfflinePacket: RakNetPacket {
    var magic: UInt128 { get }
}