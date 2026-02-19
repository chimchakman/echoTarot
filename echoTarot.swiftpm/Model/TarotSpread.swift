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
        case .oneCard: return "하나의 카드로 오늘의 메시지를 받아보세요"
        case .threeCard: return "과거, 현재, 미래를 나타내는 세 장의 카드"
        }
    }

    var positionNames: [String] {
        switch self {
        case .oneCard: return ["메시지"]
        case .threeCard: return ["과거", "현재", "미래"]
        }
    }
}
