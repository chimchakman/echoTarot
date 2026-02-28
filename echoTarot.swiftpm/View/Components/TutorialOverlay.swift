import SwiftUI

struct TutorialOverlay: View {
    let scripts: [String]
    let onComplete: () -> Void

    @State private var currentIndex = 0
    @State private var isVisible = true
    @ObservedObject private var speechService = SpeechService.shared
    @Environment(\.accessibilityVoiceOverEnabled) private var isVoiceOverEnabled

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
                speakCurrentScript(isInitial: true)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel(scripts[currentIndex])
            .accessibilityHint("Tap to move to the next step")
            .accessibilityAction(.default) {
                advanceToNext()
            }
        }
    }

    private func speakCurrentScript(isInitial: Bool = false) {
        if isVoiceOverEnabled {
            if isInitial {
                // 첫 등장 시: VoiceOver가 accessibilityLabel을 자동으로 읽으므로
                // screenChanged 신호만 보내 포커스를 이동시킴 (이중 재생 방지)
                UIAccessibility.post(notification: .screenChanged, argument: nil)
            } else {
                // 단계 전환 시: 뷰가 그대로이므로 명시적으로 announcement 전송
                UIAccessibility.post(notification: .announcement, argument: scripts[currentIndex])
            }
        } else {
            SpeechService.shared.speak(scripts[currentIndex])
        }
    }

    private func advanceToNext() {
        HapticService.shared.tap()
        if !isVoiceOverEnabled {
            SpeechService.shared.stop()
        }

        if currentIndex < scripts.count - 1 {
            currentIndex += 1
            speakCurrentScript()
        } else {
            isVisible = false
            onComplete()
        }
    }
}
