import Foundation

final class TarotImageDescriptionService: @unchecked Sendable {
    static let shared = TarotImageDescriptionService()
    private var descriptions: [Int: String] = [:]

    private init() { loadDescriptions() }

    private func loadDescriptions() {
        guard let url = Bundle.main.url(forResource: "TarotImageDescription", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let entries = try? JSONDecoder().decode([ImageDescriptionEntry].self, from: data) else { return }
        descriptions = Dictionary(uniqueKeysWithValues: entries.map { ($0.id, $0.description) })
    }

    func description(for cardId: String) -> String? {
        guard let jsonId = jsonIndex(for: cardId) else { return nil }
        return descriptions[jsonId]
    }

    private func jsonIndex(for cardId: String) -> Int? {
        if cardId.hasPrefix("major-"), let n = Int(cardId.dropFirst(6)) { return n }
        if cardId.hasPrefix("wands-"), let n = Int(cardId.dropFirst(6)) { return n + 21 }
        if cardId.hasPrefix("cups-"), let n = Int(cardId.dropFirst(5)) { return n + 35 }
        if cardId.hasPrefix("swords-"), let n = Int(cardId.dropFirst(7)) { return n + 49 }
        if cardId.hasPrefix("pentacles-"), let n = Int(cardId.dropFirst(10)) { return n + 63 }
        return nil
    }

    private struct ImageDescriptionEntry: Decodable {
        let id: Int
        let description: String
    }
}
