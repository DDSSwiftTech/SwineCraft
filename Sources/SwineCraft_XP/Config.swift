import Foundation
import Yams
import Logging

struct Config: Codable {
    static let shared = try! Config(fromPath: FileManager.default.homeDirectoryForCurrentUser.path + "/.config/swinecraft/config.yaml")
    static let logger = Logger(autoLogLevelWithLabel: "Config")

    public var worldFolder: String?
    public var playerFolder: String?

    init(fromPath path: String) throws {
        var isDir: Bool = false

        let pathURL = URL(filePath: path)
        let configDirectory = pathURL.deletingLastPathComponent().path

        if !FileManager.default.fileExists(atPath: configDirectory, isDirectory: &isDir) || !isDir {
            Self.logger.info("CREATING CONFIG DIR")
            if !isDir {
                try FileManager.default.removeItem(atPath: configDirectory)
            }
            try FileManager.default.createDirectory(atPath: configDirectory, withIntermediateDirectories: false)
        }

        self = try YAMLDecoder().decode(Self.self, from: Data(contentsOf: URL(filePath: path)))
    }

    subscript<T>(_ key: String, default defaultValue: @autoclosure () -> T) -> T {
        let mirror = Mirror(reflecting: self)

        return (mirror.children.first {$0.label == key})?.value as! T? ?? defaultValue()
    }
}