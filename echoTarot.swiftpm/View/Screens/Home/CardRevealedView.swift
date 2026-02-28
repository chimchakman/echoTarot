import SwiftUI
import UIKit

struct CardRevealedView: View {
    @ObservedObject var viewModel: HomeViewModel
    @State private var currentCardIndex = 0

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
            .accessibilityLabel("Card carousel. Swipe left or right to navigate between cards.")

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
                // Announce cards drawn, then let user explore
                let cardCount = viewModel.drawnCards.count
                let announcement = "\(cardCount) card\(cardCount == 1 ? "" : "s") drawn. Swipe to explore cards, then tap Record Reading to continue."
                SpeechService.shared.announceAfterDelay(announcement, delay: SpeechService.mediumDelay)
            }
        }
    }
}
