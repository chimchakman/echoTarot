import SwiftUI

struct CardImageDescriptionButton: View {
    let cardId: String
    @ObservedObject private var speechService = SpeechService.shared
    @State private var isThisButtonSpeaking = false

    var body: some View {
        Button(action: toggleSpeech) {
            Label(
                isThisButtonSpeaking ? "Stop description" : "Hear image description",
                systemImage: isThisButtonSpeaking ? "stop.circle.fill" : "play.circle.fill"
            )
            .font(.subheadline)
            .foregroundColor(.white.opacity(0.9))
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.indigo.opacity(0.6))
            .cornerRadius(8)
        }
        .accessibilityLabel(isThisButtonSpeaking ? "Stop image description" : "Hear image description")
        .accessibilityHint(isThisButtonSpeaking ? "Tap to stop" : "Tap to hear a description of the card image")
        .onChange(of: speechService.isSpeaking) { isSpeaking in
            if !isSpeaking {
                isThisButtonSpeaking = false
            }
        }
        .onDisappear {
            if isThisButtonSpeaking {
                SpeechService.shared.stop()
            }
        }
    }

    private func toggleSpeech() {
        if isThisButtonSpeaking {
            SpeechService.shared.stop()
            isThisButtonSpeaking = false
        } else {
            let text = TarotImageDescriptionService.shared.description(for: cardId)
            isThisButtonSpeaking = true
            HapticService.shared.impact(.light)
            SpeechService.shared.speak(text) {
                isThisButtonSpeaking = false
            }
        }
    }
}
