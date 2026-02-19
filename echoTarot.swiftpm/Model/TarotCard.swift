import Foundation

enum TarotSuit: String, Codable, CaseIterable, Sendable {
    case major = "Major Arcana"
    case cups = "Cups"
    case pentacles = "Pentacles"
    case swords = "Swords"
    case wands = "Wands"

    var koreanName: String {
        switch self {
        case .major: return "메이저 아르카나"
        case .cups: return "컵"
        case .pentacles: return "펜타클"
        case .swords: return "소드"
        case .wands: return "완드"
        }
    }
}

struct TarotCard: Identifiable, Codable, Hashable, Sendable {
    let id: String
    let name: String
    let koreanName: String
    let suit: TarotSuit
    let number: Int
    let uprightMeaning: String
    let reversedMeaning: String
    let imageName: String

    var description: String {
        "\(koreanName) - \(uprightMeaning)"
    }
}
