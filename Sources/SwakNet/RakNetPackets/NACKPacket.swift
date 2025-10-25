import NIOCore

struct NACKPacket: RakNetPacket {
    var packetType: RakNetPacketType = .ACK
    var sequenceNumber: SequenceNumber

    init(sequenceNumber: SequenceNumber) {
        self.sequenceNumber = sequenceNumber
    }

    init(from buffer: inout ByteBuffer) throws {
        let _: UInt16 = buffer.readInteger()! // record count. Useless value, can be inferred from range

        let isSingleNumberSequence = (buffer.readInteger()! as UInt8) == 1

        if isSingleNumberSequence {
            self.sequenceNumber = .single(buffer.readUInt24(endianness: .little)!)
        } else {
            self.sequenceNumber = .range(buffer.readUInt24(endianness: .little)!...buffer.readUInt24(endianness: .little)!)
        }
    }
}