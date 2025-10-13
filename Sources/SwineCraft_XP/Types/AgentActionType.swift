enum AgentActionType: UInt8, Codable {
    case Attack = 1
    case Collect = 2
    case Destroy = 3
    case DetectRedstone = 4
    case DetectObstacle = 5
    case Drop = 6
    case DropAll = 7
    case Inspect = 8
    case InspectData = 9
    case InspectItemCount = 10
    case InspectItemDetail = 11
    case InspectItemSpace = 12
    case Interact = 13
    case Move = 14
    case PlaceBlock = 15
    case Till = 16
    case TransferItemTo = 17
    case Turn = 18
}