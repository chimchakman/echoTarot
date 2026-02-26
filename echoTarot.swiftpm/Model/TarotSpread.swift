import Foundation

enum TarotSpread: String, Codable, CaseIterable, Sendable {
    case oneCard = "oneCard"
    case threeCard = "threeCard"

    var koreanName: String {
        switch self {
        case .oneCard: return "원 카드"
        case .threeCard: return "쓰리 카드"
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
        case .oneCard: return "한 장의 카드로 지금 이 순간을 살펴보세요"
        case .threeCard: return "세 장의 카드로 다양한 관점을 탐색해보세요"
        }
    }
}
