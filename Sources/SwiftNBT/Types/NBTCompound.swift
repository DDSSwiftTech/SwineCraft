import NIOCore

public struct NBTCompound: NBTEncodable {
    public typealias ValueType = [any NBTEncodable]
    
    public let tagType: NBTTagType = .COMPOUND
    
    public var name: String
    public var value: ValueType = []

    init(name: String = "", _ contents: any NBTEncodable & Sendable...) {
        self.name = name
        self.value += contents
    }

    public init(name: String, value: ValueType) {
        self.name = name
        self.value = value
    }


    public func encodeBody(_ buf: inout ByteBuffer) {
        for item in self.value {
            item.encodeFull(&buf)
        }

        buf.writeInteger(UInt8(0)) // "End tag", otherwise known as a null byte
    }

    func encode(_ buf: inout NIOCore.ByteBuffer) {
    }

    public mutating func addValues(_ vals: any NBTEncodable...) {
        self.value += vals
    }
}