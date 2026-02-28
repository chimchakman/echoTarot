import SwiftUI
import UIKit

struct CardRevealedView: View {
    @ObservedObject var viewModel: HomeViewModel
    @State private var currentCardIndex = 0
    @AccessibilityFocusState private var isRecordButtonFocused: Bool

    var body: some View {
        VStack(spacing: 16) {
            // Header
            Text("Cards Drawn")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .accessibilityAddTraits(.isHeader)

            // Card display (scrollable for multiple cards)
            TabView(selection: $currentCardIndex) {
                ForEach(Array(viewModel.drawnCards.enumerated()), id: \.offset) { index, card in
                    AccessibleCard(
                        card: card,
                        isReversed: viewModel.cardReversals[index]
                    )
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(maxHeight: 500)
            .accessibilityElement(children: .contain)

            // Navigation buttons (for 3-card spread)
            if viewModel.drawnCards.count > 1 {
                HStack(spacing: 24) {
                    // Previous button
                    Button(action: {
                        withAnimation {
                            currentCardIndex = max(0, currentCardIndex - 1)
                        }
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "chevron.left")
                                .font(.title2)
                            Text("Previous Card")
                                .font(.body)
                                .fontWeight(.medium)
                        }
                        .foregroundColor(.white)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(currentCardIndex == 0 ? Color.gray.opacity(0.3) : Color.indigo.opacity(0.8))
                        )
                    }
                    .disabled(currentCardIndex == 0)
                    .accessibilityLabel("Previous card")
                    .accessibilityHint("Navigate to the previous card in the spread")

                    Spacer()

                    // Next button
                    Button(action: {
                        withAnimation {
                            currentCardIndex = min(viewModel.drawnCards.count - 1, currentCardIndex + 1)
                        }
                    }) {
                        HStack(spacing: 8) {
                            Text("Next Card")
                                .font(.body)
                                .fontWeight(.medium)
                            Image(systemName: "chevron.right")
                                .font(.title2)
                        }
                        .foregroundColor(.white)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(currentCardIndex == viewModel.drawnCards.count - 1 ? Color.gray.opacity(0.3) : Color.indigo.opacity(0.8))
                        )
                    }
                    .disabled(currentCardIndex == viewModel.drawnCards.count - 1)
                    .accessibilityLabel("Next card")
                    .accessibilityHint("Navigate to the next card in the spread")
                }
                .padding(.horizontal)
                .frame(minHeight: 44)
            }

            // Page indicator dots
            if viewModel.drawnCards.count > 1 {
                HStack(spacing: 8) {
                    ForEach(0..<viewModel.drawnCards.count, id: \.self) { index in
                        Circle()
                            .fill(index == currentCardIndex ? Color.white : Color.white.opacity(0.4))
                            .frame(width: 8, height: 8)
                    }
                }
                .accessibilityHidden(true)
            }

            Spacer()

            // Continue button
            Button(action: {
                viewModel.startReadingRecording()
            }) {
                Text("Record Reading")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.indigo)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            .accessibilityLabel("Record reading")
            .accessibilityHint("Tap to start recording your reading")
            .accessibilityFocused($isRecordButtonFocused)

            Button(action: {
                viewModel.skipReadingRecording()
            }) {
                Text("Save without recording")
                    .font(.body)
                    .foregroundColor(.white.opacity(0.6))
            }
            .padding(.bottom, 100)
            .accessibilityLabel("Save without recording")
        }
        .padding()
        .onAppear {
            if UIAccessibility.isVoiceOverRunning {
                let cardCount = viewModel.drawnCards.count
                let intro = "\(cardCount) card\(cardCount == 1 ? "" : "s") drawn."

                // Build the chain: announce intro, then each card in sequence, then focus Record button
                SpeechService.shared.announceAfterDelay(intro, delay: SpeechService.mediumDelay) {
                    announceCardsSequentially(startingAt: 0) {
                        // All cards announced — move focus to Record Reading button
                        DispatchQueue.main.asyncAfter(deadline: .now() + SpeechService.shortDelay) {
                            isRecordButtonFocused = true
                        }
                    }
                }
            }
        }
        .onChange(of: currentCardIndex) { newIndex in
            SpeechService.shared.stop()
            if UIAccessibility.isVoiceOverRunning {
                let announcement = cardAnnouncementText(for: newIndex)
                UIAccessibility.post(notification: .announcement, argument: announcement)
            }
        }
        .onDisappear {
            SpeechService.shared.stop()
        }
    }

    // Helper function to announce cards sequentially
    private func announceCardsSequentially(startingAt index: Int, completion: @escaping () -> Void) {
        guard index < viewModel.drawnCards.count else {
            completion()
            return
        }
        let announcement = cardAnnouncementText(for: index)
        SpeechService.shared.announceAfterDelay(announcement, delay: 0) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                announceCardsSequentially(startingAt: index + 1, completion: completion)
            }
        }
    }

    // Helper function to generate card announcement text
    private func cardAnnouncementText(for index: Int) -> String {
        guard index < viewModel.drawnCards.count else { return "" }

        let card = viewModel.drawnCards[index]
        let isReversed = viewModel.cardReversals[index]
        let direction = isReversed ? "Reversed" : "Upright"
        let meaning = SettingsManager.shared.effectiveMeaning(for: card, isReversed: isReversed)
        let cardNumber = index + 1
        let totalCards = viewModel.drawnCards.count

        return "Card \(cardNumber) of \(totalCards): \(card.name), \(direction). \(meaning)"
    }
}
