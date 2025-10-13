import NIOCore

public struct NBTCompound: Sendable {
    var tagType: NBTTagType = .COMPOUND
    private var contents: [NBTNode] = []

    /// This is necessary because of a very old mistake in the NBT format
    /// 
    /// Normally, all types are simply a byte, followed by the type-specific data.
    /// For some reason, compound tags are the exception, and the root tag has a name.
    /// No other type requires a name, and indeed compound tags by themselves, do not get one
    /// They get a name like all other types, when they're in a compound tag, but why a compound tag
    /// by itself gets a name, I have no idea
    init(_ contents: NBTNode...) {
        self.contents += contents
    }

    public mutating func addValues(_ vals: NBTNode...) {
        self.contents += vals
    }

    func encodeListElement(_ buf: inout ByteBuffer) {
        for value in self.contents {
            var _buf = value.encodeNBT()

            buf.writeBuffer(&_buf)
        }   

        buf.writeInteger(UInt8(0)) // "End tag", otherwise known as a null byte
    }
}