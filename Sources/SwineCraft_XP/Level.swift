import SwiftNBT

struct Level {
    public let biomeOverride: String
    public let levelCompound: NBTCompound

    // init(_ levelCompound: NBTCompound) {
    //     self.levelCompound = levelCompound
    // }

    public func getLevelData(path: [String]) -> (any NBTEncodable)? {
        var currentItem: (any NBTEncodable)? = self.levelCompound

        for item in path {
            switch currentItem {
                case is NBTCompound:
                    currentItem = (currentItem as! NBTCompound).value.first {$0.name == item}
                case is NBTList:
                    currentItem = (currentItem as! NBTList).value[Int(item)!]
                default:
                    break
            }
        }

        return currentItem
    }
}