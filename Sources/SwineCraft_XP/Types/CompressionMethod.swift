enum CompressionMethod: UInt16 {
    case ZLib
    case Snappy
    case None = 0xFFFF
}