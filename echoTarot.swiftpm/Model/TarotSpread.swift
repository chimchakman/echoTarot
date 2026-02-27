import Foundation

enum TarotSpread: String, Codable, CaseIterable, Sendable {
    case oneCard = "oneCard"
    case threeCard = "threeCard"

    var name: String {
        switch self {
        case .oneCard: return "One Card"
        case .threeCard: return "Three Card"
        }
    }

    var cardCount: Int {
        switch self {
        case .oneCard: return 1
        case .threeCard: return 3
        }
    }

    var description: String {
        switch self {
        case .oneCard: return "Explore this moment with a single card"
        case .threeCard: return "Explore multiple perspectives with three cards"
        }
    }
}
