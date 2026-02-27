import Foundation
import SwiftUI

enum LogsSortOption: String, CaseIterable {
    case dateDescending = "Newest First"
    case dateAscending = "Oldest First"
}

@MainActor
final class LogsViewModel: ObservableObject {
    @Published var readings: [any ReadingProtocol] = []
    @Published var filteredReadings: [any ReadingProtocol] = []
    @Published var sortOption: LogsSortOption = .dateDescending
    @Published var selectedHashtag: String?
    @Published var selectedCardId: String?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let allCards: [TarotCard] = TarotCardData.allCards

    init() {
        loadReadings()
    }

    func loadReadings() {
        isLoading = true

        do {
            readings = try PersistenceManager.shared.fetchAllReadings()
            applyFiltersAndSort()
            isLoading = false
        } catch {
            errorMessage = "Unable to load readings"
            isLoading = false
        }
    }

    func applyFiltersAndSort() {
        var result = readings

        if let hashtag = selectedHashtag {
            result = result.filter { $0.hashtags.contains(hashtag) }
        }

        if let cardId = selectedCardId {
            result = result.filter { $0.cardIds.contains(cardId) }
        }

        switch sortOption {
        case .dateDescending:
            result.sort { $0.date > $1.date }
        case .dateAscending:
            result.sort { $0.date < $1.date }
        }

        filteredReadings = result
    }

    func setSortOption(_ option: LogsSortOption) {
        sortOption = option
        HapticService.shared.selection()
        SpeechService.shared.speak("Sorted by \(option.rawValue)")
        applyFiltersAndSort()
    }

    func filterByHashtag(_ hashtag: String?) {
        selectedHashtag = hashtag
        HapticService.shared.selection()
        if let tag = hashtag {
            SpeechService.shared.speak("Filter applied: \(tag)")
        } else {
            SpeechService.shared.speak("Filter cleared")
        }
        applyFiltersAndSort()
    }

    func filterByCard(_ cardId: String?) {
        selectedCardId = cardId
        HapticService.shared.selection()
        if let id = cardId, let card = allCards.first(where: { $0.id == id }) {
            SpeechService.shared.speak("Filter applied: \(card.name)")
        } else {
            SpeechService.shared.speak("Filter cleared")
        }
        applyFiltersAndSort()
    }

    func clearFilters() {
        selectedHashtag = nil
        selectedCardId = nil
        HapticService.shared.tap()
        SpeechService.shared.speak("All filters cleared")
        applyFiltersAndSort()
    }

    func deleteReading(_ reading: any ReadingProtocol) {
        do {
            if let questionPath = reading.questionAudioPath {
                AudioFileManager.shared.deleteRecording(at: questionPath)
            }
            if let readingPath = reading.readingAudioPath {
                AudioFileManager.shared.deleteRecording(at: readingPath)
            }

            try PersistenceManager.shared.deleteReading(reading)
            HapticService.shared.success()
            SpeechService.shared.speak("Reading deleted")
            loadReadings()
        } catch {
            HapticService.shared.error()
            SpeechService.shared.speak("Failed to delete reading")
        }
    }

    func getCard(for id: String) -> TarotCard? {
        allCards.first { $0.id == id }
    }

    func getAllHashtags() -> [String] {
        let readingTags = readings.flatMap { $0.hashtags }
        let masterTags = HashtagManager.shared.hashtags
        return Array(Set(readingTags).union(masterTags)).sorted()
    }

    // MARK: - Card Dictionary Methods

    func getCardsBySuit(_ suit: TarotSuit) -> [TarotCard] {
        return allCards.filter { $0.suit == suit }
    }

    func getReadings(for cardId: String) -> [any ReadingProtocol] {
        var result = readings.filter { $0.cardIds.contains(cardId) }

        if let hashtag = selectedHashtag {
            result = result.filter { $0.hashtags.contains(hashtag) }
        }

        switch sortOption {
        case .dateDescending:
            result.sort { $0.date > $1.date }
        case .dateAscending:
            result.sort { $0.date < $1.date }
        }

        return result
    }

    func getReadingCount(for cardId: String) -> Int {
        return readings.filter { $0.cardIds.contains(cardId) }.count
    }
}
