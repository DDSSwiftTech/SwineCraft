import NIOCore

public struct NBTCompound: Sendable, Equatable {
    var tagType: NBTTagType = .COMPOUND
    private var contents: [NBTNode] = []

    init(_ contents: NBTNode...) {
        self.contents += contents
    }

    public mutating func addValues(_ vals: NBTNode...) {
        self.contents += vals
    }

    func encodeBody(_ buf: inout ByteBuffer) {
        for value in self.contents {
            var _buf = value.encodeNBT()

            buf.writeBuffer(&_buf)
        }   

        buf.writeInteger(UInt8(0)) // "End tag", otherwise known as a null byte
    }
}