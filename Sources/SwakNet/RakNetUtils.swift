import NIOCore
import Foundation
import FoundationNetworking

public extension ByteBuffer {
    typealias UInt24 = UInt32
    
    mutating func readMagic() -> UInt128? {
        guard let magic: UInt128 = self.readInteger() else {
            return nil
        }

        return magic
    }

    mutating func readTime() -> UInt64? {
        guard let time: UInt64 = self.readInteger() else {
            return nil
        }

        return time
    }

    mutating func readGUID() -> UInt64? {
        guard let guid: UInt64 = self.readInteger() else {
            return nil
        }

        return guid
    }

    mutating func readServerIDString() -> String? {
        guard let serverIDStringLength: UInt16 = self.readInteger() else {
            return nil
        }

        guard let serverIDStringBytes = self.readBytes(length: Int(serverIDStringLength)) else {
            return nil
        }

        return String(serverIDStringBytes.map {Character(Unicode.Scalar($0))})
    }

    mutating func readProtocolVersion() -> UInt8? {
        guard let protocolVersion = self.readBytes(length: 1) else {
            return nil
        }

        return protocolVersion[0]
    }

    mutating func readUInt24(endianness: Endianness = .little) -> UInt32? { // Returns UInt32, but only ever reads 3 bytes of data
        guard let uint24_3bytes = self.readBytes(length: 3) else {
            return nil
        }

        var bytes: [UInt8]

        switch endianness {
            case .little:
                bytes = uint24_3bytes + [0]
            case .big:
                bytes = ([0] + uint24_3bytes).reversed() // read as big-endian, but reverse for Swift
        }

        return bytes.withUnsafeBytes { buf in
            return buf.baseAddress!.withMemoryRebound(to: UInt32.self, capacity: 1) { pointer in
                return pointer.pointee
            }
        }
    }

    mutating func writeUInt24(_ uint24le: UInt32, endianness: Endianness) {
        var bytes: [UInt8] = [
            UInt8(uint24le >> 16 & 0xff),
            UInt8(uint24le >> 8 & 0xff),
            UInt8(uint24le & 0xff)
        ]
        
        if endianness == .little{
            bytes.reverse()
        }

        self.writeBytes(bytes)
    }

    mutating func readAddress() -> RakNetAddress {

        if self.readBytes(length: 1)?.first == 4 {
            return RakNetAddress(ip: .v4(
                    ~self.readInteger()!,
                    ~self.readInteger()!,
                    ~self.readInteger()!,
                    ~self.readInteger()!),
                port:self.readInteger()!
            )
        } else {
            let addr_family: UInt16 = self.readInteger()!
            let port: UInt16 = self.readInteger()!
            let flow_info: UInt32 = self.readInteger()!
            let addr = RakNetAddressIP.v6(self.readInteger()!, self.readInteger()!, self.readInteger()!, self.readInteger()!, self.readInteger()!, self.readInteger()!, self.readInteger()!, self.readInteger()!, addr_family: addr_family, flow_info: flow_info, scope_id: self.readInteger()!)

            return RakNetAddress(ip: addr, port: port)
        }
    }
}

class RakNetUtils {
    public static func getLocalInterfaceAddresses() -> [RakNetAddress] {
        return try! System.enumerateDevices().filter {($0.address?.protocol == .inet || $0.address?.protocol == .inet6) && $0.address != nil}.map {RakNetAddress(from: $0.address!)!}
    }
}