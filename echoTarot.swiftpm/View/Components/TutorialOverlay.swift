import SwiftUI

struct TutorialOverlay: View {
    let scripts: [String]
    let onComplete: () -> Void

    @State private var currentIndex = 0
    @State private var isVisible = true
    @ObservedObject private var speechService = SpeechService.shared

    var body: some View {
        if isVisible {
            ZStack {
                // Dimmed background
                Color.black.opacity(0.85)
                    .ignoresSafeArea()

                VStack(spacing: 32) {
                    // Tutorial icon
                    Image(systemName: "hand.point.up.left.fill")
                        .font(.system(size: 64))
                        .foregroundColor(.white)

                    // Current script text
                    Text(scripts[currentIndex])
                        .font(.title2)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)

                    // Progress indicator
                    HStack(spacing: 8) {
                        ForEach(0..<scripts.count, id: \.self) { index in
                            Circle()
                                .fill(index == currentIndex ? Color.white : Color.white.opacity(0.3))
                                .frame(width: 8, height: 8)
                        }
                    }

                    // Navigation hint
                    Text("Tap to continue")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                advanceToNext()
            }
            .onAppear {
                speakCurrentScript()
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Tutorial: \(scripts[currentIndex])")
            .accessibilityHint("Tap to move to the next step")
            .accessibilityAction(.default) {
                advanceToNext()
            }
        }
    }

    private func speakCurrentScript() {
        SpeechService.shared.speak(scripts[currentIndex])
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
