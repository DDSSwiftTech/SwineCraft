public struct Experiments: MCPEPacketEncodable {
    public struct Experiment: MCPEPacketEncodable {
        public let name: String
        public let enabled: Bool
    }

    public let experimentList: [Experiment]
    public let wereAnyExperimentsEverToggled: Bool
}