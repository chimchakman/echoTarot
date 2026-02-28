import SwiftUI

struct ReadingCompleteView: View {
    @ObservedObject var viewModel: HomeViewModel
    @AccessibilityFocusState private var isHomeButtonFocused: Bool

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // Success icon
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)

            Text("Reading saved")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)

            Text("You can view it in the Logs tab")
                .font(.body)
                .foregroundColor(.white.opacity(0.8))

            Spacer()

            // New reading button
            Button(action: {
                viewModel.reset()
            }) {
                Text("Back to Home")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.indigo)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            .padding(.bottom, 100)
            .accessibilityLabel("Back to Home")
            .accessibilityHint("Tap to return to the start")
            .accessibilityFocused($isHomeButtonFocused)
        }
        .padding()
        .onAppear {
            HapticService.shared.success()
            if UIAccessibility.isVoiceOverRunning {
                // Step 1: Set focus first
                DispatchQueue.main.asyncAfter(deadline: .now() + SpeechService.shortDelay) {
                    isHomeButtonFocused = true
                }
                // Step 2: Announce AFTER focus has been read (longer delay)
                SpeechService.shared.announceAfterDelay(
                    "Reading saved successfully. Tap Back to Home to start a new reading.",
                    delay: SpeechService.focusThenAnnounceDelay
                )
            }
        }
    }
}
