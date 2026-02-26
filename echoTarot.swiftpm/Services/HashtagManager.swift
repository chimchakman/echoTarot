import Foundation

@MainActor
final class HashtagManager: ObservableObject {
    static let shared = HashtagManager()

    private let defaults = UserDefaults.standard
    private let key = "echoTarot.hashtags"

    @Published private(set) var hashtags: [String] = []

    private init() {
        load()
    }

    func add(_ hashtag: String) {
        let trimmed = hashtag.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty, !hashtags.contains(trimmed) else { return }
        hashtags.append(trimmed)
        hashtags.sort()
        save()
    }

    func rename(from oldName: String, to newName: String) {
        let trimmed = newName.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty, let index = hashtags.firstIndex(of: oldName) else { return }
        hashtags[index] = trimmed
        hashtags.sort()
        save()
    }

    func remove(_ hashtag: String) {
        hashtags.removeAll { $0 == hashtag }
        save()
    }

    func contains(_ hashtag: String) -> Bool {
        hashtags.contains(hashtag)
    }

    // MARK: - Merge from readings (backward compatibility)

    func mergeFromReadings(_ readingHashtags: [String]) {
        var changed = false
        for tag in readingHashtags {
            let trimmed = tag.trimmingCharacters(in: .whitespaces)
            if !trimmed.isEmpty && !hashtags.contains(trimmed) {
                hashtags.append(trimmed)
                changed = true
            }
        }
        if changed {
            hashtags.sort()
            save()
        }
    }

    // MARK: - Persistence

    private func load() {
        guard let data = defaults.data(forKey: key),
              let decoded = try? JSONDecoder().decode([String].self, from: data) else {
            return
        }
        hashtags = decoded
    }

    private func save() {
        if let encoded = try? JSONEncoder().encode(hashtags) {
            defaults.set(encoded, forKey: key)
        }
    }
}
