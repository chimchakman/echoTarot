import SwiftUI

struct CardImageDescriptionButton: View {
    let card: TarotCard

    @ObservedObject private var speechService = SpeechService.shared

    private var description: String? {
        TarotImageDescriptionService.shared.description(for: card.id)
    }

    var body: some View {
        if let description {
            Button(action: {
                HapticService.shared.tap()
                if speechService.isSpeaking {
                    SpeechService.shared.stop()
                } else {
                    SpeechService.shared.speak(description)
                }
            }) {
                HStack(spacing: 6) {
                    Image(systemName: speechService.isSpeaking ? "stop.circle.fill" : "play.circle.fill")
                        .font(.title3)
                    Text(speechService.isSpeaking ? "설명 정지" : "이미지 설명 듣기")
                        .font(.subheadline)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(Color.indigo.opacity(0.7))
                .cornerRadius(20)
            }
            .accessibilityLabel("카드 이미지 설명 듣기")
            .accessibilityHint("탭하면 카드 이미지를 음성으로 설명합니다")
        }
    }
}
