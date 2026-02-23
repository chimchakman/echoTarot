import SwiftUI

struct TarotCardDictionaryView: View {
    @ObservedObject var viewModel: LogsViewModel
    @State private var selectedCard: TarotCard?

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
            SpeechService.shared.speak("타로 카드 사전")
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
                Text(suit.koreanName)
                    .font(.headline)
                    .foregroundColor(.white)

                Spacer()

                Text("\(cards.count)장")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.6))
            }
            .padding(.vertical, 8)
        }
        .padding()
        .background(Color.black.opacity(0.3))
        .cornerRadius(12)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(suit.koreanName), \(cards.count)장의 카드")
    }

    private func cardButton(card: TarotCard) -> some View {
        Button(action: {
            HapticService.shared.tap()
            SpeechService.shared.speak(card.koreanName)
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

                Text(card.koreanName)
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.8))
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
            }
        }
        .accessibilityLabel(card.koreanName)
        .accessibilityAddTraits(.isButton)
        .accessibilityHint("두 번 탭하여 \(card.koreanName) 카드가 포함된 리딩 기록 보기")
    }
}
