import NIO

enum DataFlags: UInt8 {
    case UNRELIABLE
    case UNRELIABLE_SEQUENCED
    case RELIABLE
    case RELIABLE_ORDERED
    case RELIABLE_SEQUENCED
    case UNRELIABLE_ACK
    case RELIABLE_ACK
    case RELIABLE_ORDERED_ACK
}

struct DataPacket: RakNetPacket {
    var packetType: RakNetPacketType = .DATA_PACKET_0

    let sequenceNumber: UInt32 // UInt24LE
    let messages: [Message]

    struct Message { // message header: 26 bytes
        let flags: DataFlags
        let isFragment: Bool
        let length: UInt16
        let reliableFrameIndex: UInt32? // UInt24LE
        let sequencedFrameIndex: UInt32? // UInt24LE
        let orderedFrameIndex: UInt32? // UInt24LE
        let orderChannel: UInt8?
        let compoundSize: Int32?
        let compoundID: Int16?
        let index: Int32?
        let body: ByteBuffer
    }

    init(sequenceNumber: UInt32, messages: [Message]) {
        self.sequenceNumber = sequenceNumber
        self.messages = messages
    }

    init(from buffer: inout ByteBuffer) throws {
        guard let sequenceNumber = buffer.readUInt24(endianness: .little) else {
            throw RakNetError.PacketDecode(self.packetType)
        }

        self.sequenceNumber = sequenceNumber

        var messages: [Message] = []

        while buffer.readableBytes != 0 {
            guard let flags: UInt8 = buffer.readInteger(),
            let length: UInt16 = buffer.readInteger() else {
                throw RakNetError.PacketDecode(self.packetType)
            }

            let flags_struct = DataFlags(rawValue: flags >> 5) ?? .UNRELIABLE

            let reliableFrameIndex: UInt32?

            if [DataFlags.RELIABLE, .RELIABLE_ORDERED, .RELIABLE_ACK, .RELIABLE_ORDERED_ACK, .RELIABLE_SEQUENCED].contains(flags_struct) {
                guard let idx: UInt32 = buffer.readUInt24(endianness: .little) else {
                    throw RakNetError.PacketDecode(self.packetType)
                }

                reliableFrameIndex = idx
            } else {
                reliableFrameIndex = nil
            }

            let sequencedFrameIndex: UInt32?

            if [DataFlags.UNRELIABLE_SEQUENCED, .RELIABLE_SEQUENCED].contains(flags_struct) {
                guard let idx: UInt32 = buffer.readUInt24(endianness: .little) else {
                    throw RakNetError.PacketDecode(self.packetType)
                }

                sequencedFrameIndex = idx
            } else {
                sequencedFrameIndex = nil
            }

            let orderedFrameIndex: UInt32?
            let orderChannel: UInt8?

            if [DataFlags.RELIABLE_ORDERED, .RELIABLE_ORDERED_ACK].contains(flags_struct) {
                guard let idx: UInt32 = buffer.readUInt24(endianness: .little), let chan: UInt8 = buffer.readInteger() else {
                    throw RakNetError.PacketDecode(self.packetType)
                }

                orderedFrameIndex = idx
                orderChannel = chan
            } else {
                orderedFrameIndex = nil
                orderChannel = nil
            }

            let is_fragmented = ((flags & 0b00010000) >> 4) == 1

            let compoundSize: Int32?
            let compoundID: Int16?
            let index: Int32?
            let isFragment: Bool
            
            if is_fragmented {
                guard let _compoundSize: Int32 = buffer.readInteger(),
                let _compoundID: Int16 = buffer.readInteger(),
                let _index: Int32 = buffer.readInteger() else {
                    throw RakNetError.PacketDecode(self.packetType)
                }

                compoundSize = _compoundSize
                compoundID = _compoundID
                index = _index
                isFragment = true
            } else {
                compoundID = nil
                compoundSize = nil
                index = nil
                isFragment = false
            }

            let body = ByteBuffer(bytes: buffer.readBytes(length: Int(length / 8)) ?? [])

            messages.append(Message(
                flags: flags_struct,
                isFragment: isFragment,
                length: length,
                reliableFrameIndex: reliableFrameIndex,
                sequencedFrameIndex: sequencedFrameIndex,
                orderedFrameIndex: orderedFrameIndex,
                orderChannel: orderChannel,
                compoundSize: compoundSize,
                compoundID: compoundID,
                index: index,
                body: body)
            )
        }

        self.messages = messages
    }

    mutating func setData(packetType: RakNetPacketType) {
        self.packetType = packetType
    }

    func encode() throws -> ByteBuffer {
        var buffer = ByteBuffer()

        buffer.writeInteger(self.packetType.rawValue)
        buffer.writeUInt24(self.sequenceNumber, endianness: .little)
        
        for message in messages {
            
            buffer.writeInteger(((message.flags.rawValue << 1) | (message.isFragment ? 1 : 0)) << 4)
            buffer.writeInteger(message.length)

            if message.reliableFrameIndex != nil {
                buffer.writeUInt24(message.reliableFrameIndex!, endianness: .little)
            }

            if message.sequencedFrameIndex != nil {
                buffer.writeUInt24(message.sequencedFrameIndex!, endianness: .little)
            }

            if message.orderedFrameIndex != nil {
                buffer.writeUInt24(message.orderedFrameIndex!, endianness: .little)
                buffer.writeInteger(message.orderChannel!)
            }

            if message.isFragment {
                buffer.writeInteger(message.compoundSize!)
                buffer.writeInteger(message.compoundID!)
                buffer.writeInteger(message.index!)
            }

            var body = message.body

            buffer.writeBuffer(&body)
        }

        return buffer
    }
}