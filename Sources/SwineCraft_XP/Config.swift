import Foundation
import Yams

struct Config: Codable {
    static let shared = try! Config(fromPath: FileManager.default.homeDirectoryForCurrentUser.path + "/.config/swinecraft/config.yaml")

    public var worldFolder: String?
    public var playerFolder: String?

    enum ConfigCodingKey: CodingKey {
        case worldFolder
        case playerFolder
    }
    
    init(fromPath path: String) throws {
        var isDir: Bool = false

        let pathURL = URL(filePath: path)
        let configDirectory = pathURL.deletingLastPathComponent().path

        if !FileManager.default.fileExists(atPath: configDirectory, isDirectory: &isDir) || !isDir {
            print("CREATING CONFIG DIR")
            if !isDir {
                try FileManager.default.removeItem(atPath: configDirectory)
            }
            try FileManager.default.createDirectory(atPath: configDirectory, withIntermediateDirectories: false)
        }

        self = try YAMLDecoder().decode(Self.self, from: Data(contentsOf: URL(filePath: path)))
    }

    // we'll encode defaults in here to make it seamless
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: ConfigCodingKey.self)

        self.worldFolder = (try? container.decode(String.self, forKey: .worldFolder)) ?? "worlds"
        self.playerFolder = (try? container.decode(String.self, forKey: .playerFolder)) ?? "players"
    }
}