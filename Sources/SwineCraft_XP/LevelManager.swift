class LevelManager {
    @MainActor static let shared = LevelManager()

    private let levels: [Level] = []
    
    init() {
        Config.shared.worldFolder
    }
}