enum NBTError: Error {
    enum BUFFER_DECODE_REASON {
        case TAG_TYPE
        case NAME_STRING
        case ARRAY_COUNT
        case STRING
        case CORRUPT_FILE
        case LIST_ELEMENTS_DONT_MATCH
    }

    case BUFFER_DECODE(reason: BUFFER_DECODE_REASON)
}