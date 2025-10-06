import Foundation
import NIOCore

extension RakNet {
    public enum AddressIP: Hashable, Sendable {
        case v4(UInt8, UInt8, UInt8, UInt8)
        case v6(UInt16, UInt16, UInt16, UInt16, UInt16, UInt16, UInt16, UInt16, addr_family: UInt16, flow_info: UInt32, scope_id: UInt32)
    }
    
    public struct Address: Hashable, Sendable {
        let ip: AddressIP
        let port: UInt16

        public init(ip: AddressIP, port: UInt16) {
            self.ip = ip
            self.port = port
        }

        public init?(from socketAddress: SocketAddress) {
            guard let socketIP = socketAddress.ipAddress else {
                return nil
            }

            switch socketAddress.protocol {
                case .inet:
                    let ipSplit = socketIP.split(separator: ".").map {UInt8($0)!}

                    self.ip = .v4(ipSplit[0], ipSplit[1], ipSplit[2], ipSplit[3])
                case .inet6:
                    let doubleColonSplit = socketIP.split(separator: "::")

                    let leftBytes = doubleColonSplit[0].split(separator: ":").map {UInt16($0, radix: 16)!}
                    let rightBytes = doubleColonSplit.count > 1 ? doubleColonSplit[1].split(separator: ":").map {UInt16($0, radix: 16)!} : []
                    let middleBytes = [UInt16](repeating: 0, count: 8 - leftBytes.count - rightBytes.count)

                    let v6Shorts = leftBytes + middleBytes + rightBytes

                    self.ip = .v6(v6Shorts[0], v6Shorts[1], v6Shorts[2], v6Shorts[3], v6Shorts[4], v6Shorts[5], v6Shorts[6], v6Shorts[7], addr_family: UInt16(socketAddress.protocol.rawValue), flow_info: 0, scope_id: 0)
                default:
                    self.ip = .v4(0, 0, 0, 0)
            }

            self.port = UInt16(socketAddress.port ?? 0)
        }
    }
}