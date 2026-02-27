import SwiftUI

struct ReadingRowView: View {
    let reading: any ReadingProtocol
    @ObservedObject var viewModel: LogsViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(formatDate(reading.date))
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))

                Spacer()

                Text(spreadTypeText)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.indigo.opacity(0.6))
                    .cornerRadius(8)
            }

            HStack(spacing: 8) {
                ForEach(Array(reading.cardIds.enumerated()), id: \.offset) { index, cardId in
                    if let card = viewModel.getCard(for: cardId) {
                        VStack(spacing: 4) {
                            Image(card.imageName)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 50)
                                .rotationEffect(.degrees(reading.cardReversals[index] ? 180 : 0))

                            Text(card.koreanName)
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.8))
                                .lineLimit(1)
                        }
                        .frame(minWidth: 60)
                    }
                }
                Spacer()
            }

            if !reading.hashtags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(reading.hashtags, id: \.self) { tag in
                            Text("#\(tag)")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.6))
                        }
                    }
                }
            }

            HStack(spacing: 12) {
                if reading.questionAudioPath != nil {
                    Label("질문", systemImage: "mic.fill")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.5))
                }

                if reading.readingAudioPath != nil {
                    Label("리딩", systemImage: "waveform")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.5))
                }
            }
        }
        .padding()
        .background(Color.black.opacity(0.5))
        .cornerRadius(12)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityDescription)
    }

    private var spreadTypeText: String {
        reading.spreadType == "oneCard" ? "원 카드" : "쓰리 카드"
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy년 M월 d일 HH:mm"
        return formatter.string(from: date)
    }

    private var accessibilityDescription: String {
        let cards = reading.cardIds.compactMap { viewModel.getCard(for: $0)?.koreanName }
        return "\(formatDate(reading.date)), \(spreadTypeText), 카드: \(cards.joined(separator: ", "))"
    }
}
