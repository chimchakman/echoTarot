import Foundation

final class TarotImageDescriptionService: @unchecked Sendable {
    static let shared = TarotImageDescriptionService()

    private init() {}

    func description(for cardId: String) -> String {
        TarotImageDescriptionData.descriptions[cardId] ?? "이 카드의 이미지 설명을 불러올 수 없습니다."
    }
}
