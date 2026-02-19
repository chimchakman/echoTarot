import SwiftUI

struct ReadingRecordingView: View {
    @ObservedObject var viewModel: HomeViewModel

    var body: some View {
        VStack(spacing: 24) {
            Text("리딩을 녹음하세요")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)

            Text("카드가 전하는 메시지를 말씀해주세요")
                .font(.body)
                .foregroundColor(.white.opacity(0.8))

            // Show drawn cards summary
            HStack(spacing: 8) {
                ForEach(Array(viewModel.drawnCards.enumerated()), id: \.offset) { index, card in
                    VStack(spacing: 4) {
                        Image(card.imageName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 60)
                            .rotationEffect(.degrees(viewModel.cardReversals[index] ? 180 : 0))
                        Text(card.koreanName)
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
            }
            .padding()

            Spacer()

            VoiceRecordButton(recordingType: .reading) { url in
                viewModel.completeReadingRecording(audioURL: url)
            }

            Spacer()

            Button(action: {
                viewModel.skipReadingRecording()
            }) {
                Text("건너뛰기")
                    .font(.body)
                    .foregroundColor(.white.opacity(0.6))
            }
            .padding(.bottom, 100)
            .accessibilityLabel("리딩 녹음 건너뛰기")
        }
        .padding()
    }
}
