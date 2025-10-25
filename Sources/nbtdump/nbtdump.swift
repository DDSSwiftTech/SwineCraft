import Foundation
import SwiftNBT

@main
class Main {
    static func main() async throws {
        let fileArg = ProcessInfo.processInfo.arguments[1]
        let file = try NBTFile(fromFile: URL(filePath: fileArg))

        for tag in file.fileCompound.value {
            print(tag)
        }
    }
}