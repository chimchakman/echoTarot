import SwiftUI

struct TutorialOverlay: View {
    let scripts: [String]
    let onComplete: () -> Void

    @State private var currentIndex = 0
    @State private var isVisible = true

    var body: some View {
        if isVisible && !scripts.isEmpty {
            ZStack {
                // Visual layer — hidden from VoiceOver so it never auto-reads labels
                ZStack {
                    Color.black.opacity(0.85)
                        .ignoresSafeArea()

                    VStack(spacing: 32) {
                        Image(systemName: "hand.point.up.left.fill")
                            .font(.system(size: 64))
                            .foregroundColor(.white)

                        Text(scripts[currentIndex])
                            .font(.title2)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)

                        HStack(spacing: 8) {
                            ForEach(0..<scripts.count, id: \.self) { index in
                                Circle()
                                    .fill(index == currentIndex ? Color.white : Color.white.opacity(0.3))
                                    .frame(width: 8, height: 8)
                            }
                        }

                        Text("Tap to continue")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
                .accessibilityHidden(true)

                // Interaction layer — single accessibility element VoiceOver focuses on
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {
                        advanceToNext()
                    }
                    .accessibilityElement()
                    .accessibilityLabel(scripts[currentIndex])
                    .accessibilityHint("Double-tap to move to the next step")
                    .accessibilityAddTraits(.startsMediaSession)
                    .accessibilityAction(.default) {
                        advanceToNext()
                    }
            }
            .onAppear {
                speakCurrentScript(isInitial: true)
            }
        }
    }

    private func speakCurrentScript(isInitial: Bool = false) {
        // On initial appearance, VoiceOver auto-focuses the interaction element
        // and reads its accessibilityLabel — so skip speakAlways to avoid overlap.
        // For all subsequent steps, VoiceOver does not auto-announce label changes,
        // so speakAlways is the sole audio source.
        if isInitial && SpeechService.shared.isVoiceOverRunning { return }
        SpeechService.shared.speakAlways(scripts[currentIndex], rate: SpeechService.tutorialSpeechRate)
    }

    private func advanceToNext() {
        HapticService.shared.tap()
        SpeechService.shared.stop()

        if currentIndex < scripts.count - 1 {
            currentIndex += 1
            speakCurrentScript()
        } else {
            isVisible = false
            onComplete()
        }
    }
}
