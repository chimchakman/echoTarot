import Foundation

enum TarotSuit: String, Codable, CaseIterable, Sendable {
    case major = "Major Arcana"
    case cups = "Cups"
    case pentacles = "Pentacles"
    case swords = "Swords"
    case wands = "Wands"

    var name: String {
        switch self {
        case .major: return "Major Arcana"
        case .cups: return "Cups"
        case .pentacles: return "Pentacles"
        case .swords: return "Swords"
        case .wands: return "Wands"
        }
    }
}

struct TarotCard: Identifiable, Codable, Hashable, Sendable {
    let id: String
    let name: String
    let suit: TarotSuit
    let number: Int
    let uprightMeaning: String
    let reversedMeaning: String
    let imageName: String

    var description: String {
        "\(name) - \(uprightMeaning)"
    }
}
