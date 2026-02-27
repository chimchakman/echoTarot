import SwiftUI

struct ReadingRecordingView: View {
    @ObservedObject var viewModel: HomeViewModel

    var body: some View {
        VStack(spacing: 24) {
            Text("Record your reading")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)

            Text("Speak the message the cards are conveying")
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
                        Text(card.name)
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
                Text("Skip")
                    .font(.body)
                    .foregroundColor(.white.opacity(0.6))
            }
            .padding(.bottom, 100)
            .accessibilityLabel("Skip reading recording")
        }
        .padding()
    }
}
