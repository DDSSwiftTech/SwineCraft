import NIOCore

struct NACKPacket: RakNet.Packet {
    var packetType: RakNet.PacketType = .ACK
    var recordCount: UInt16 {
        switch self.sequenceNumber {
            case .single(_):
                return 1
            case .range(let range):
                return UInt16(truncatingIfNeeded: range.count)
        }
    }
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

    func encode() throws -> ByteBuffer {
        var buffer = ByteBuffer()

        buffer.writeInteger(packetType.rawValue)
        buffer.writeInteger(recordCount)

        switch self.sequenceNumber {
            case .single(let seq):
                buffer.writeInteger(UInt8(1)) // Is single sequence number
                buffer.writeUInt24(seq, endianness: .little)
            case .range(let seqRange):
                buffer.writeInteger(UInt8(0)) // Is not single sequence number
                buffer.writeUInt24(seqRange.lowerBound, endianness: .little)
                buffer.writeUInt24(seqRange.upperBound, endianness: .little)
        }

        return buffer
    }
}