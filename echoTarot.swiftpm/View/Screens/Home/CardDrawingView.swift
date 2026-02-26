import SwiftUI

struct CardDrawingView: View {
    @ObservedObject var viewModel: HomeViewModel

    var body: some View {
        VStack(spacing: 24) {
            Text("카드를 뽑는 중...")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)

            Text("\(viewModel.selectedSpread.koreanName)")
                .font(.title3)
                .foregroundColor(.white.opacity(0.8))

            Spacer()

            // Card animation area
            HStack(spacing: 16) {
                ForEach(0..<viewModel.selectedSpread.cardCount, id: \.self) { index in
                    cardSlot(at: index)
                }
            }
            .padding()

            Spacer()

            // Progress indicator
            if viewModel.drawnCards.count < viewModel.selectedSpread.cardCount {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
            }
        }
        .padding()
    }

    @ViewBuilder
    private func cardSlot(at index: Int) -> some View {
        if index < viewModel.drawnCards.count {
            // Card has been drawn - show card back with animation
            Image("cardBack")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: 100)
                .rotationEffect(.degrees(viewModel.cardReversals[index] ? 180 : 0))
                .transition(.scale.combined(with: .opacity))
                .accessibilityLabel("\(index + 1)번째 카드: 카드가 뽑혔습니다")
        } else {
            // Empty slot
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.white.opacity(0.3), lineWidth: 2)
                .frame(width: 80, height: 120)
                .accessibilityLabel("\(index + 1)번째 카드: 대기 중")
        }
    }
}
