import SwiftUI
import UIKit

struct QuestionRecordingView: View {
    @ObservedObject var viewModel: HomeViewModel
    @AccessibilityFocusState private var isRecordButtonFocused: Bool

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            Text("Record your question")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)

            Text("Speak the question on your mind")
                .font(.body)
                .foregroundColor(.white.opacity(0.8))

            Spacer()
            VoiceRecordButton(recordingType: .question) { url in
                viewModel.completeQuestionRecording(audioURL: url)
            }
            .accessibilityFocused($isRecordButtonFocused)

            Spacer()
            // Skip button
            Button(action: {
                viewModel.questionAudioURL = nil
                HapticService.shared.tap()
                if !UIAccessibility.isVoiceOverRunning {
                    SpeechService.shared.speak("Skipping question recording")
                }
                viewModel.state = .hashtagInput
            }) {
                Text("Skip")
                    .font(.body)
                    .foregroundColor(.white.opacity(0.6))
            }
            .padding(.bottom, 100)
            .accessibilityLabel("Skip question recording")
        }
        .padding()
        .onAppear {
            // Delay longer than SwiftUI transition (0.35s) to avoid race with IdleStateView
            DispatchQueue.main.asyncAfter(deadline: .now() + SpeechService.mediumDelay) {
                isRecordButtonFocused = true
            }
        }
    }
}
