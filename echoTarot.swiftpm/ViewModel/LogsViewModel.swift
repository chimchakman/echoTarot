import Foundation
import SwiftUI

enum LogsSortOption: String, CaseIterable {
    case dateDescending = "최신순"
    case dateAscending = "오래된순"
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
            errorMessage = "기록을 불러올 수 없습니다"
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
        SpeechService.shared.speak("\(option.rawValue)으로 정렬")
        applyFiltersAndSort()
    }

    func filterByHashtag(_ hashtag: String?) {
        selectedHashtag = hashtag
        HapticService.shared.selection()
        if let tag = hashtag {
            SpeechService.shared.speak("\(tag) 필터 적용")
        } else {
            SpeechService.shared.speak("필터 해제")
        }
        applyFiltersAndSort()
    }

    func filterByCard(_ cardId: String?) {
        selectedCardId = cardId
        HapticService.shared.selection()
        if let id = cardId, let card = allCards.first(where: { $0.id == id }) {
            SpeechService.shared.speak("\(card.koreanName) 필터 적용")
        } else {
            SpeechService.shared.speak("필터 해제")
        }
        applyFiltersAndSort()
    }

    func clearFilters() {
        selectedHashtag = nil
        selectedCardId = nil
        HapticService.shared.tap()
        SpeechService.shared.speak("모든 필터 해제")
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
            SpeechService.shared.speak("기록이 삭제되었습니다")
            loadReadings()
        } catch {
            HapticService.shared.error()
            SpeechService.shared.speak("삭제에 실패했습니다")
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
