import NIOCore
import Foundation
import SwakNet

struct LoginPacket: MCPEPacket {
    var packetType: MCPEPacketType = .LOGIN

    var protocolVersion: Int32
    var chainData: ChainData
    var skinData: (SkinSignature, Skin)

    init(from buffer: inout ByteBuffer) throws {
        self.protocolVersion = buffer.readInteger()!
        
        let jsonDataBuffLength = buffer.readUnsignedVarInt().backingInt
        var jsonDataBuf = ByteBuffer(bytes: buffer.readBytes(length: Int(jsonDataBuffLength))!)

        let chainDataLength: UInt32 = jsonDataBuf.readInteger(endianness: .little)!
        let chainDataString = String(jsonDataBuf.readBytes(length: Int(chainDataLength))!.map {Character(Unicode.Scalar($0))})

        do {
            chainData = try JSONDecoder().decode(ChainData.self, from: chainDataString.data(using: .utf8)!)
        } catch (let e) {
            print(e)
            throw e
        }

        let skinDataLength: UInt32 = jsonDataBuf.readInteger(endianness: .little)!

        let skinData = String(jsonDataBuf.readBytes(length: Int(skinDataLength))!.map {Character(Unicode.Scalar($0))})
        
        let skinDataItems = skinData.split(separator: ".")

        do {
            let skinSignature = try JSONDecoder().decode(SkinSignature.self, from: Data(MCPEBase64Encoded: skinDataItems[0] + "", options: .ignoreUnknownCharacters)!)

            self.skinData = (skinSignature, try JSONDecoder().decode(Skin.self, from: Data(MCPEBase64Encoded: skinDataItems[1] + "", options: .ignoreUnknownCharacters)!))
        } catch (let e) {
            print(e)

            throw e
        }
    }
}

extension LoginPacket {
    struct ChainData: Codable {
        enum ChainDataKey: CodingKey {
            case Token
            case Certificate
            case AuthenticationType
        }

        struct TokenStruct: Codable {
            let sub: String
            let ipt: String
            let iat: Int
            let mid: String
            let tid: String
            let pfcd: Int
            let cpk: String
            let xid: String
            let xname: String
            let exp: Int
            let iss: String
            let aud: String
        }
        let AuthenticationType: Int
        var Certificate: String
        let Token: TokenStruct

        init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: ChainDataKey.self)

            self.AuthenticationType = try container.decode(Int.self, forKey: .AuthenticationType)
            self.Certificate = try container.decode(String.self, forKey: .Certificate)
            self.Token = try JSONDecoder().decode(
                TokenStruct.self,
                from: Data(MCPEBase64Encoded: String(try container.decode(String.self, forKey: .Token).split(separator: ".")[1]), options: .ignoreUnknownCharacters)!
            )
        }
    }

    struct SkinSignature: Codable {
        let alg: String
        let x5u: String
    }

    struct Skin: Codable {
        struct AnimatedImageDatum: Codable {
            let AnimationExpression: Int
            let Frames: Float
            let Image: Data
            let ImageHeight: Int
            let ImageWidth: Int
            let `Type`: Int
        }

        // Sample JSON
        // {\"IsDefault\":true,\"PackId\":\"2099de18-429a-465a-a49b-fc4710a17bb3\",\"PieceId\":\"8f96d1f8-e9bb-40d2-acc8-eb79746c5d7c\",\"PieceType\":\"persona_skeleton\",\"ProductId\":\"\"}
        struct PersonaPiece: Codable {
            let IsDefault: Bool
            let PackId: UUID
            let PieceId: UUID
            let PieceType: String
            let ProductId: String
            var productUUID: UUID? {
                return UUID(uuidString: self.ProductId) ?? nil
            }
        }
        

        // Sample JSON
        // {\"Colors\":[\"#0\",\"#0\",\"#ff45220e\",\"#0\"],\"PieceType\":\"persona_mouth\"}
        struct PieceTintColor: Codable {
            let Colors: [String]
            let PieceType: String
        }

        let AnimatedImageData: [AnimatedImageDatum]
        let ArmSize: String
        let CapeData: String
        let CapeId: String
        let CapeImageHeight: Int
        let CapeImageWidth: Int
        let CapeOnClassicSkin: Bool
        let ClientRandomId: Int
        let CompatibleWithClientSideChunkGen: Bool
        let CurrentInputMode: Int
        let DefaultInputMode: Int
        let DeviceId: String
        let DeviceModel: String
        let DeviceOS: Int
        let GameVersion: String
        let GraphicsMode: Int
        let GuiScale: Int
        let IsEditorMode: Bool
        let LanguageCode: String
        let MaxViewDistance: Int
        let MemoryTier: Int
        let OverrideSkin: Bool
        let PersonaPieces: [PersonaPiece]
        let PersonaSkin: Bool
        let PieceTintColors: [PieceTintColor]
        let PlatformOfflineId: String
        let PlatformOnlineId: String
        let PlatformType: Int
        let PremiumSkin: Bool
        let SelfSignedId: UUID
        let ServerAddress: String
        let SkinAnimationData: String
        let SkinColor: String
        let SkinData: Data
        let SkinGeometryDataEngineVersion: String
        let SkinId: String
        let SkinImageHeight: Int
        let SkinImageWidth: Int
        let SkinResourcePatch: Data
        let ThirdPartyName: String
        let TrustedSkin: Bool
        let UIProfile: Int
    }
}