public struct Experiments {
    public struct Experiment {
        public let name: String
        public let enabled: Bool
    }

    public let experimentList: [Experiment]
    public let wereAnyExperimentsEverToggled: Bool
}