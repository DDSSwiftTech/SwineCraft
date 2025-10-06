import NIOCore

struct ConnectionRequestAcceptedPacket: RakNetPacket {
    var packetType: RakNetPacketType = .ONLINE_CONNECTION_REQUEST_ACCEPTED

    let clientAddress: RakNetAddress
    let systemIndex: UInt16 = 0
    var internalIDs: [RakNetAddress] {
        var addrs = RakNetUtils.getLocalInterfaceAddresses().map {RakNetAddress(ip: $0.ip, port: 19132)}

        if addrs.count > 10 {
            addrs = Array(addrs[0...9])
        }

        let padding = 10 - addrs.count

        return addrs + [RakNetAddress](repeating: RakNetAddress(ip: .v4(0, 0, 0, 0), port: 0), count: padding)
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