import Foundation
import SwiftUI

enum HomeState: Equatable {
    case idle
    case questionRecording
    case hashtagInput
    case cardDrawing
    case cardRevealed
    case readingRecording
    case complete
}

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var state: HomeState = .idle {
        didSet { NavigationState.shared.isReadingActive = (state != .idle) }
    }
    @Published var selectedSpread: TarotSpread = SettingsManager.shared.defaultSpread
    @Published var drawnCards: [TarotCard] = []
    @Published var cardReversals: [Bool] = []
    @Published var questionAudioURL: URL?
    @Published var readingAudioURL: URL?
    @Published var isAnimating = false
    @Published var hashtags: [String] = []

    private let allCards = TarotCardData.allCards

    func startReading() {
        HapticService.shared.tap()
        SpeechService.shared.speak("질문을 녹음해주세요. 탭하여 녹음을 시작하세요.")
        state = .questionRecording
    }

    func completeQuestionRecording(audioURL: URL) {
        questionAudioURL = audioURL
        HapticService.shared.success()
        SpeechService.shared.speak("질문이 녹음되었습니다. 태그를 선택하세요.")

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.state = .hashtagInput
        }
    }

    func drawCards() {
        state = .cardDrawing
        isAnimating = true
        drawnCards = []
        cardReversals = []

        // Shuffle and draw cards
        var shuffledDeck = allCards.shuffled()

        for i in 0..<selectedSpread.cardCount {
            let card = shuffledDeck.removeFirst()
            let isReversed = Bool.random()

            // Animate card drawing with delay
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 1.0) { [weak self] in
                guard let self = self else { return }

                HapticService.shared.cardDrawn()
                self.drawnCards.append(card)
                self.cardReversals.append(isReversed)

                // Speak card info
                let reversedText = isReversed ? "역방향" : ""
                SpeechService.shared.speak("\(i + 1)번째 카드, \(card.koreanName) \(reversedText)")

                // Check if all cards are drawn
                if self.drawnCards.count == self.selectedSpread.cardCount {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                        self?.revealCards()
                    }
                }
            }
        }
    }

    func revealCards() {
        isAnimating = false
        state = .cardRevealed
        HapticService.shared.cardRevealed()

        // Speak all card meanings
        var speechTexts: [String] = []
        for (index, card) in drawnCards.enumerated() {
            let isReversed = cardReversals[index]
            let meaning = SettingsManager.shared.effectiveMeaning(for: card, isReversed: isReversed)
            speechTexts.append("\(index + 1)번째 카드: \(card.koreanName). \(meaning)")
        }

        SpeechService.shared.speakWithPause(speechTexts, pauseDuration: 1.0)
    }

    func startReadingRecording() {
        SpeechService.shared.stop()
        HapticService.shared.tap()
        SpeechService.shared.speak("리딩을 녹음해주세요. 탭하여 녹음을 시작하세요.")
        state = .readingRecording
    }

    func completeReadingRecording(audioURL: URL) {
        readingAudioURL = audioURL
        saveReading()
    }

    func completeHashtagInput(selectedHashtags: [String]) {
        hashtags = selectedHashtags
        HapticService.shared.success()
        SpeechService.shared.speak("태그가 선택되었습니다. 카드를 뽑겠습니다.")

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.drawCards()
        }
    }

    func skipHashtagInput() {
        hashtags = []
        HapticService.shared.tap()
        SpeechService.shared.speak("태그 선택을 건너뜁니다. 카드를 뽑겠습니다.")

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.drawCards()
        }
    }

    func saveReading() {
        do {
            try PersistenceManager.shared.saveReading(
                spreadType: selectedSpread.rawValue,
                questionAudioPath: questionAudioURL?.path,
                readingAudioPath: readingAudioURL?.path,
                cardIds: drawnCards.map { $0.id },
                cardReversals: cardReversals,
                hashtags: hashtags
            )
            HapticService.shared.success()
            SpeechService.shared.speak("리딩이 저장되었습니다.")
            state = .complete
        } catch {
            HapticService.shared.error()
            SpeechService.shared.speak("저장에 실패했습니다. 다시 시도해주세요.")
        }
    }

    func skipReadingRecording() {
        readingAudioURL = nil
        saveReading()
    }

    func cancelReading() {
        HapticService.shared.impact(.medium)
        SpeechService.shared.stop()
        reset()
    }

    func reset() {
        state = .idle
        drawnCards = []
        cardReversals = []
        questionAudioURL = nil
        readingAudioURL = nil
        isAnimating = false
        hashtags = []
        selectedSpread = SettingsManager.shared.defaultSpread
    }

    func changeSpread() {
        selectedSpread = selectedSpread == .oneCard ? .threeCard : .oneCard
        HapticService.shared.selection()
        SpeechService.shared.speak("\(selectedSpread.koreanName) 선택됨")
    }
}
