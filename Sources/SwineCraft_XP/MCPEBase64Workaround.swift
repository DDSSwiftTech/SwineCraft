import Foundation

extension Data {
    init?(MCPEBase64Encoded: String, options: Base64DecodingOptions) {
        var data = Data(base64Encoded: String(MCPEBase64Encoded), options: .ignoreUnknownCharacters)

        // Unfortunately, Minecraft sends invalid base64 strings, missing required padding
        // This is VERY stupid, but we have to check, and this is the easiest way to do it
        // Probably there is a better way...
        // Base64 requires zero, one or two padding characters depending on number of bytes encoded
        // If we have nil here, lets try the padding options and hope for the best!

        if data == nil {
            data = Data(base64Encoded: MCPEBase64Encoded + "=", options: .ignoreUnknownCharacters)
        }

        if data == nil {
            data = Data(base64Encoded: MCPEBase64Encoded + "==", options: .ignoreUnknownCharacters)
        }

        if data != nil {
            self = data!
        } else {
            return nil
        }
    }
}