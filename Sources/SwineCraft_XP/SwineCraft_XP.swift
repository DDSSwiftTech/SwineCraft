import SwakNet

@main
class Main {
    static func main() async throws {
        let raknet = SwakNetServer()

        try await raknet.listen(onIP: "0.0.0.0", andPort: 19132, serverIDString: "MCPE;Dedicated Server;\(RakNetProtocolInfo.VERSION);1.21.102;5;10;9989168348586418088;Bedrock level;Survival;1;19132;19133;0;", dataHandler: MCPEHandler())
    }
}