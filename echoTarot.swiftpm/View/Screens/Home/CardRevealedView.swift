import SwiftUI

struct CardRevealedView: View {
    @ObservedObject var viewModel: HomeViewModel
    @State private var currentCardIndex = 0

    var body: some View {
        VStack(spacing: 16) {
            // Header
            Text("뽑힌 카드")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)

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
                Text("리딩 녹음하기")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.indigo)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            .accessibilityLabel("리딩 녹음하기")
            .accessibilityHint("탭하여 리딩 녹음 시작")

            Button(action: {
                viewModel.skipReadingRecording()
            }) {
                Text("녹음 없이 저장")
                    .font(.body)
                    .foregroundColor(.white.opacity(0.6))
            }
            .padding(.bottom, 100)
            .accessibilityLabel("녹음 없이 저장하기")
        }
        .padding()
    }
}
