import NIOCore

enum CompressionMethod: Int16 {
    // Despite everywhere you look ZLIB is being mentioned as the compression format used by Minecraft, ZLIB is in fact NOT used
    // There are no ZLIB headers to be found. Minecraft works with raw DEFLATE streams with no headers
    // Someone somewhere goofed up the naming, but here we'll call it correctly
    case DEFLATE
    case Snappy
    case None = -1
}