import Foundation

class RakNetConfig: @unchecked Sendable {
    let GUID = UInt64.random(in: 0...UInt64.max)
    private let startTime = Date()
    var timeSinceLaunch: UInt64 {
        return UInt64(Date().timeIntervalSince(startTime) * 1000)
    }
    static let shared = RakNetConfig()
}