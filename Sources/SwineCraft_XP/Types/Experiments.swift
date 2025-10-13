struct Experiments {
    struct Experiment {
        let name: String
        let enabled: Bool
    }

    let experimentList: [Experiment]
    let wereAnyExperimentsEverToggled: Bool
}