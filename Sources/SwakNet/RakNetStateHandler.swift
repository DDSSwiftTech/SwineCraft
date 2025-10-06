import NIOCore

typealias RakNetConnectionID = RakNetAddress

struct RakNetConnectionState: Sendable {
    var connectionID: RakNetConnectionID
    var connectionMTU: UInt16
    var clientTime: UInt64
    var clientDataPacketSequenceNumber: UInt32 = 0
    var pendingFragments: [DataPacket.Message]
    var pendingOutOfOrder: [DataPacket.Message]
    var pendingUnackedPackets: [DataPacket]
    var reliableFrameIDX: UInt32 // UInt24LE
    var clientAddresses: [RakNetAddress]
}

enum RakNetDecapsulationFailure {
    case Fragment // added to fragment queue
    case OutOfOrder // added to order queue
    case OutOfSequence // dropped
    case NoActiveState // received a decapsulation for non-existant state, or perhaps state that was lost
}

@MainActor
final class RakNetStateHandler: Sendable {
    static let shared: RakNetStateHandler = RakNetStateHandler()

    private var activeConnectionState: [RakNetConnectionID: RakNetConnectionState] = [:]

    // This is run as early as possible to initialize state once the intent to connect is established
    // Most of these values will get modified almost immediately
    func initializeState(clientTime: UInt64, connectionID: RakNetConnectionID) {
        self.activeConnectionState[connectionID] = RakNetConnectionState(
            connectionID: connectionID,
            connectionMTU: 0,
            clientTime: clientTime,
            clientDataPacketSequenceNumber: 0,
            pendingFragments: [],
            pendingOutOfOrder: [],
            pendingUnackedPackets: [],
            reliableFrameIDX: 0,
            clientAddresses: []
        )
    }

    func discardState(connectionID: RakNetConnectionID) {
        if self.activeConnectionState.keys.contains(connectionID) {
            self.activeConnectionState.removeValue(forKey: connectionID)
        }
    }

    func setClientTime(connectionID: RakNetConnectionID, time: UInt64) {
        self.activeConnectionState[connectionID]?.clientTime = time
    }

    func setConnectionMTU(connectionID: RakNetConnectionID, mtu: UInt16) {
        self.activeConnectionState[connectionID]?.connectionMTU = mtu
    }

    func getConnectionMTU(connectionID: RakNetConnectionID) -> UInt16? {
        return self.activeConnectionState[connectionID]?.connectionMTU
    }

    func setClientAddresses(connectionID: RakNetConnectionID, addresses: [RakNetAddress]) {
        self.activeConnectionState[connectionID]?.clientAddresses = addresses
    }

    func getClientAddresses(connectionID: RakNetConnectionID) -> [RakNetAddress]? {
        return self.activeConnectionState[connectionID]?.clientAddresses
    }

    func getSeqNumber(connectionID: RakNetConnectionID) -> UInt32 {
        guard self.activeConnectionState[connectionID] != nil else {
            return 0
        }

        defer {self.activeConnectionState[connectionID]!.clientDataPacketSequenceNumber += 1}

        return self.activeConnectionState[connectionID]!.clientDataPacketSequenceNumber
    }

    func removeAckedPacket(seqNum: UInt32, connectionID: RakNetConnectionID) {
        self.activeConnectionState[connectionID]?.pendingUnackedPackets.removeAll {$0.sequenceNumber == seqNum}
    }

    func getUnackedPacket(seqNum: UInt32, connectionID: RakNetConnectionID) -> DataPacket? {
        return self.activeConnectionState[connectionID]?.pendingUnackedPackets.first {$0.sequenceNumber == seqNum}
    }

    func getState(connectionID: RakNetConnectionID) -> RakNetConnectionState? {
        return self.activeConnectionState[connectionID]
    }

    func setState(connectionID: RakNetConnectionID, state: RakNetConnectionState) {
        self.activeConnectionState[connectionID] = state
    }

    func decapsulateDataPacket(packet: DataPacket, connectionID: RakNetConnectionID) -> [Result<ByteBuffer, RakNetError>] {
        guard let activeStateStruct = self.activeConnectionState[connectionID] else {
            return [.failure(.Decapsulation(.NoActiveState))]
        }

        var messageDecodeResults: [Result<ByteBuffer, RakNetError>] = [] // This holds the decapsulated buffers for the various received messages

        for message in packet.messages {
            if message.isFragment {
                let relatedFragments = activeStateStruct.pendingFragments.filter({$0.compoundID == message.compoundID}) + [message]

                if relatedFragments.count == message.compoundSize! {
                    var combinedBuffer = ByteBuffer()

                    relatedFragments.sorted {$0.index! < $1.index!}.forEach {
                        var body = $0.body

                        combinedBuffer.writeBuffer(&body)
                    }

                    self.activeConnectionState[activeStateStruct.connectionID]?.pendingFragments = [] // reset pending fragments, all have been used

                    messageDecodeResults.append(.success(combinedBuffer))
                } else {
                    self.activeConnectionState[activeStateStruct.connectionID]?.pendingFragments.append(message)
                }
            } else {
                messageDecodeResults.append(.success(message.body))
            }
        }

        return messageDecodeResults
    }

    func encapsulate(packets: [RakNetPacket], connectionID: RakNetConnectionID) -> DataPacket {
        return encapsulate(buffers: packets.map {try! $0.encode()}, connectionID: connectionID)
    }

    func encapsulate(buffers: [ByteBuffer], connectionID: RakNetConnectionID) -> DataPacket {
        let seqNum = self.activeConnectionState[connectionID]!.clientDataPacketSequenceNumber

        self.activeConnectionState[connectionID]!.clientDataPacketSequenceNumber += 1
        var messages: [DataPacket.Message] = []

        for buffer in buffers {
            let dataMessage = DataPacket.Message(
                flags: .RELIABLE_ORDERED,
                isFragment: false,
                length: UInt16(buffer.readableBytes * 8),
                reliableFrameIndex: self.activeConnectionState[connectionID]?.reliableFrameIDX,
                sequencedFrameIndex: nil,
                orderedFrameIndex: self.activeConnectionState[connectionID]?.reliableFrameIDX,
                orderChannel: 0,
                compoundSize: nil,
                compoundID: nil,
                index: nil,
                body: buffer
            )

            messages.append(dataMessage)

            self.activeConnectionState[connectionID]?.reliableFrameIDX += 1
        }

        var returnData = DataPacket(sequenceNumber: seqNum, messages: messages)

        returnData.setData(packetType: .DATA_PACKET_4)

        self.activeConnectionState[connectionID]?.pendingUnackedPackets.append(returnData)

        return returnData
    }
}