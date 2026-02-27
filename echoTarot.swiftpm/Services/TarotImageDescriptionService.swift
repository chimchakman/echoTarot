import Foundation

final class TarotImageDescriptionService: @unchecked Sendable {
    static let shared = TarotImageDescriptionService()

    private init() {}

    func description(for cardId: String) -> String {
        TarotImageDescriptionData.descriptions[cardId] ?? "Unable to load image description for this card."
    }
}
