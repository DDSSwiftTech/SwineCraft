public enum RakNetEvent {
    case DISCONNECTED(source: RakNet.Address, reason: String)
}