import SwiftUI

struct TarotCardDictionaryView: View {
    @ObservedObject var viewModel: LogsViewModel
    @State private var selectedCard: TarotCard?
    @Environment(\.accessibilityVoiceOverEnabled) private var isVoiceOverEnabled

    private let suits: [TarotSuit] = [.major, .cups, .pentacles, .swords, .wands]

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12, pinnedViews: []) {
                ForEach(suits, id: \.self) { suit in
                    suitSection(for: suit)
                }
            }
            .padding()
            .padding(.bottom, 100)
        }
        .sheet(item: $selectedCard) { card in
            CardReadingsListView(card: card, viewModel: viewModel)
        }
        .onAppear {
            if !isVoiceOverEnabled {
                SpeechService.shared.speak("Tarot Card Dictionary")
            }
            HapticService.shared.tap()
        }
    }

    private func suitSection(for suit: TarotSuit) -> some View {
        let cards = viewModel.getCardsBySuit(suit)

        return DisclosureGroup {
            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: 70), spacing: 12)],
                spacing: 12
            ) {
                ForEach(cards) { card in
                    cardButton(card: card)
                }
            }
            .padding(.top, 8)
        } label: {
            HStack {
                Text(suit.name)
                    .font(.headline)
                    .foregroundColor(.white)

                Spacer()

                Text("\(cards.count) cards")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.6))
            }
            .padding(.vertical, 8)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("\(suit.name), \(cards.count) cards")
        }
        .padding()
        .background(Color.black.opacity(0.5))
        .cornerRadius(12)
    }

    private func cardButton(card: TarotCard) -> some View {
        Button(action: {
            HapticService.shared.tap()
            if !isVoiceOverEnabled {
                SpeechService.shared.speak(card.name)
            }
            selectedCard = card
        }) {
            VStack(spacing: 4) {
                Image(card.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 100)
                    .cornerRadius(8)
                    .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                    .accessibilityHidden(true)

                Text(card.name)
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.8))
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
            }
        }
        .accessibilityLabel(card.name)
        .accessibilityAddTraits(.isButton)
        .accessibilityHint("Double-tap to view readings containing \(card.name)")
    }
}
