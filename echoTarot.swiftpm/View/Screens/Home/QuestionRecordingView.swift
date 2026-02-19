import SwiftUI

struct QuestionRecordingView: View {
    @ObservedObject var viewModel: HomeViewModel

    var body: some View {
        VStack(spacing: 24) {
            Text("질문을 녹음하세요")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)

            Text("마음속 질문을 말씀해주세요")
                .font(.body)
                .foregroundColor(.white.opacity(0.8))

            Spacer()

            VoiceRecordButton(recordingType: .question) { url in
                viewModel.completeQuestionRecording(audioURL: url)
            }

            Spacer()

            // Skip button
            Button(action: {
                viewModel.questionAudioURL = nil
                HapticService.shared.tap()
                SpeechService.shared.speak("질문 녹음을 건너뜁니다")
                viewModel.drawCards()
            }) {
                Text("건너뛰기")
                    .font(.body)
                    .foregroundColor(.white.opacity(0.6))
            }
            .padding(.bottom, 100)
            .accessibilityLabel("질문 녹음 건너뛰기")
        }
        .padding()
    }
}
