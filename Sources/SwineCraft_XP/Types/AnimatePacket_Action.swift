enum AnimatePacket_Action: UInt8, Codable {
    case NoAction = 0
    case Swing = 1
    case WakeUp = 3
    case CriticalHit = 4
    case MagicCriticalHit = 5
}