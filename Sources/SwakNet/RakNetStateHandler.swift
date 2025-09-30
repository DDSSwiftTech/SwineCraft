import NIOCore

extension RakNet {
    typealias ConnectionID = RakNet.Address

    struct ConnectionState {
        var connectionID: ConnectionID
        var connectionMTU: UInt16
        var clientTime: UInt64
        var clientDataPacketSequenceNumber: UInt32 = 0
        var pendingFragments: [DataPacket.Message]
        var pendingOutOfOrder: [DataPacket.Message]
        var pendingUnackedPackets: [DataPacket]
        var clientAddresses: [Address]
    }

    enum DecapsulationFailure {
        case Fragment // added to fragment queue
        case OutOfOrder // added to order queue
        case OutOfSequence // dropped
        case NoActiveState // received a decapsulation for non-existant state, or perhaps state that was lost
    }

    final class StateHandler {
        var activeConnectionState: [ConnectionID: ConnectionState] = [:]

        // This is run as early as possible to initialize state once the intent to connect is established
        // Most of these values will get modified almost immediately
        func initializeState(clientTime: UInt64, connectionID: ConnectionID) {
            self.activeConnectionState[connectionID] = ConnectionState(
                connectionID: connectionID,
                connectionMTU: 0,
                clientTime: clientTime,
                clientDataPacketSequenceNumber: 0,
                pendingFragments: [],
                pendingOutOfOrder: [],
                pendingUnackedPackets: [],
                clientAddresses: []
            )
        }

        func discardState(connectionID: ConnectionID) {
            if self.activeConnectionState.keys.contains(connectionID) {
                self.activeConnectionState.removeValue(forKey: connectionID)
            }
        }

        func setClientTime(connectionID: ConnectionID, time: UInt64) {
            self.activeConnectionState[connectionID]?.clientTime = time
        }

        func setConnectionMTU(connectionID: ConnectionID, mtu: UInt16) {
            self.activeConnectionState[connectionID]?.connectionMTU = mtu
        }

        func getConnectionMTU(connectionID: ConnectionID) -> UInt16? {
            return self.activeConnectionState[connectionID]?.connectionMTU
        }

        func setClientAddresses(connectionID: ConnectionID, addresses: [Address]) {
            self.activeConnectionState[connectionID]?.clientAddresses = addresses
        }

        func getClientAddresses(connectionID: ConnectionID) -> [Address]? {
            return self.activeConnectionState[connectionID]?.clientAddresses
        }

        func getSeqNumber(connectionID: ConnectionID) -> UInt32 {
            guard self.activeConnectionState[connectionID] != nil else {
                return 0
            }

            defer {self.activeConnectionState[connectionID]!.clientDataPacketSequenceNumber += 1}

            return self.activeConnectionState[connectionID]!.clientDataPacketSequenceNumber
        }

        func removeAckedPacket(seqNum: UInt32, connectionID: ConnectionID) {
            self.activeConnectionState[connectionID]?.pendingUnackedPackets.removeAll {$0.sequenceNumber == seqNum}
        }

        func getUnackedPacket(seqNum: UInt32, connectionID: ConnectionID) -> DataPacket? {
            return self.activeConnectionState[connectionID]?.pendingUnackedPackets.first {$0.sequenceNumber == seqNum}
        }

        func getState(connectionID: ConnectionID) -> ConnectionState? {
            return self.activeConnectionState[connectionID]
        }

        func setState(connectionID: ConnectionID, state: ConnectionState) {
            self.activeConnectionState[connectionID] = state
        }

        func decapsulateDataPacket(packet: DataPacket, connectionID: ConnectionID) -> [Result<ByteBuffer, RakNet.Error>] {
            guard let activeStateStruct = self.activeConnectionState[connectionID] else {
                return [.failure(.Decapsulation(.NoActiveState))]
            }

            var returnBuffers: [ByteBuffer] = []

            for message in packet.messages {
                if message.isFragment {
                    let relatedFragments = activeStateStruct.pendingFragments.filter({$0.compoundID == message.compoundID}) + [message]

                    if relatedFragments.count == message.compoundSize! {
                        var combinedBuffer = ByteBuffer()

                        relatedFragments.sorted {$0.index! < $1.index!}.forEach {
                            var body = $0.body

                            combinedBuffer.writeBuffer(&body)
                        }

                        self.activeConnectionState[activeStateStruct.connectionID]!.pendingFragments = [] // reset pending fragments, all have been used

                        returnBuffers.append( combinedBuffer)
                    }
                } else {
                    returnBuffers.append(message.body)
                }
            }

            return returnBuffers.map {.success($0)}
        }

        func encapsulate(packets: [RakNet.Packet], connectionID: ConnectionID) -> DataPacket {
            let seqNum = self.activeConnectionState[connectionID]!.clientDataPacketSequenceNumber

            self.activeConnectionState[connectionID]!.clientDataPacketSequenceNumber += 1
            var messages: [DataPacket.Message] = []

            for packet in packets {
                let packetBytes = try! packet.encode()

                let dataMessage = DataPacket.Message(
                    flags: .RELIABLE_ORDERED,
                    isFragment: false,
                    length: UInt16(packetBytes.readableBytes * 8),
                    reliableFrameIndex: 0,
                    sequencedFrameIndex: nil,
                    orderedFrameIndex: 0,
                    orderChannel: 0,
                    compoundSize: nil,
                    compoundID: nil,
                    index: nil,
                    body: packetBytes
                )

                messages.append(dataMessage)
            }

            var returnData = DataPacket(sequenceNumber: seqNum, messages: messages)

            returnData.setData(packetType: .DATA_PACKET_4)

            self.activeConnectionState[connectionID]?.pendingUnackedPackets.append(returnData)

            return returnData
        }
    }
}