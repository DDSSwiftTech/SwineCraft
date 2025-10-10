enum ZLIBError: Int32 {
    case VERSION = -6
    case BUFFER = -5
    case MEMORY = -4
    case DATA = -3
    case STREAM = -2
    case SYSTEM = -1
    case OK = 0
    case STREAM_END = 1
    case NEED_DICT = 2
}