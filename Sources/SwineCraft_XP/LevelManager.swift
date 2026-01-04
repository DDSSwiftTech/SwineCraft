import LevelDB

class LevelManager {
    @MainActor static let shared = LevelManager()

    private let levels: [Level] = []
    private let leveldbOptions: OpaquePointer
    
    init() {
        Config.shared.worldFolder
        leveldbOptions = leveldb_options_create()

        print(leveldbOptions)
    }
}