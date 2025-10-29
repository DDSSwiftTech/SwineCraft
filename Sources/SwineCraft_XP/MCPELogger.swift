import Logging
import Foundation

extension Logger {
    init(autoLogLevelWithLabel label: String) {
        self.init(label: label)

        self.logLevel = {
            switch ProcessInfo.processInfo.environment["LOGLEVEL"] {
                case "DEBUG":
                    .debug
                case "CRITICAL":
                    .critical
                case "ERROR":
                    .error
                case "INFO":
                    .info
                case "NOTICE":
                    .notice
                case "TRACE":
                    .trace
                case "WARNING":
                    .warning
                default:
                    .info
            }
        }()
    }
}