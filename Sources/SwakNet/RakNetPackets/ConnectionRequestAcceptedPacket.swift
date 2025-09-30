import NIOCore

struct ConnectionRequestAcceptedPacket: RakNet.Packet {
    var packetType: RakNet.PacketType = .ONLINE_CONNECTION_REQUEST_ACCEPTED

    let clientAddress: RakNet.Address
    let systemIndex: UInt16 = 0
    var internalIDs: [RakNet.Address] {
        var addrs = RakNet.Utils.getLocalInterfaceAddresses().map {RakNet.Address(ip: $0.ip, port: 19132)}

        if addrs.count > 10 {
            addrs = Array(addrs[0...9])
        }

        let padding = 10 - addrs.count

        return addrs + [RakNet.Address](repeating: RakNet.Address(ip: .v4(0, 0, 0, 0), port: 0), count: padding)
    }
    let requestTime: UInt64
    let time: UInt64

    func encode() throws -> ByteBuffer {
        var buffer = ByteBuffer() 

        var addrBuf = self.clientAddress.encode()

        buffer.writeInteger(self.packetType.rawValue)
        buffer.writeBuffer(&addrBuf)
        buffer.writeInteger(systemIndex)
        for var idBuffer in internalIDs.map({$0.encode()}) {
            buffer.writeBuffer(&idBuffer)
        }
        buffer.writeInteger(requestTime)
        buffer.writeInteger(time)

        return buffer
    }
}