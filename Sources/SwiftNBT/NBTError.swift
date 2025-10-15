enum NBTError: Error {
    enum BUFFER_DECODE_REASON {
        case NAME_STRING
        case ARRAY_COUNT
        case STRING
    }

    case BUFFER_DECODE(reason: BUFFER_DECODE_REASON)
}