import SwiftUI

struct ReadingDetailView: View {
    let reading: any ReadingProtocol
    @ObservedObject var viewModel: LogsViewModel
    @ObservedObject var audioManager = AudioFileManager.shared
    @Environment(\.dismiss) private var dismiss

    @State private var currentCardIndex = 0
    @State private var showDeleteConfirmation = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    Text(formatDate(reading.date))
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    TabView(selection: $currentCardIndex) {
                        ForEach(Array(reading.cardIds.enumerated()), id: \.offset) { index, cardId in
                            if let card = viewModel.getCard(for: cardId) {
                                AccessibleCard(
                                    card: card,
                                    isReversed: reading.cardReversals[index]
                                )
                                .tag(index)
                            }
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .frame(height: 400)

                    if reading.cardIds.count > 1 {
                        HStack(spacing: 8) {
                            ForEach(0..<reading.cardIds.count, id: \.self) { index in
                                Circle()
                                    .fill(index == currentCardIndex ? Color.accentColor : Color.secondary.opacity(0.4))
                                    .frame(width: 8, height: 8)
                            }
                        }
                        .accessibilityHidden(true)
                    }

                    VStack(spacing: 16) {
                        if let questionPath = reading.questionAudioPath {
                            audioPlayButton(title: "Question Recording", path: questionPath)
                        }

                        if let readingPath = reading.readingAudioPath {
                            audioPlayButton(title: "Reading Recording", path: readingPath)
                        }
                    }
                    .padding()

                    if !reading.hashtags.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Tags")
                                .font(.headline)

                            FlowLayout(spacing: 8) {
                                ForEach(reading.hashtags, id: \.self) { tag in
                                    Text("#\(tag)")
                                        .font(.subheadline)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color.indigo.opacity(0.2))
                                        .cornerRadius(16)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                    }

                    if let notes = reading.notes, !notes.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Notes")
                                .font(.headline)

                            Text(notes)
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Reading Detail")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button(role: .destructive) {
                        showDeleteConfirmation = true
                    } label: {
                        Image(systemName: "trash")
                    }
                }
            }
            .alert("Delete this reading?", isPresented: $showDeleteConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    viewModel.deleteReading(reading)
                    dismiss()
                }
            } message: {
                Text("Deleted readings cannot be recovered.")
            }
        }
    }

    private func audioPlayButton(title: String, path: String) -> some View {
        Button(action: {
            HapticService.shared.tap()
            let url = URL(fileURLWithPath: path)
            if audioManager.isPlaying {
                audioManager.stopPlaying()
            } else {
                try? audioManager.playAudio(from: url)
                SpeechService.shared.speak("Playing \(title)")
            }
        }) {
            HStack {
                Image(systemName: audioManager.isPlaying ? "stop.fill" : "play.fill")
                Text(title)
                Spacer()
            }
            .padding()
            .background(Color.secondary.opacity(0.1))
            .cornerRadius(12)
        }
        .accessibilityLabel("\(title) \(audioManager.isPlaying ? "Stop" : "Play")")
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "EEEE, MMM d, yyyy HH:mm"
        return formatter.string(from: date)
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.width ?? 0, subviews: subviews, spacing: spacing)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(
                at: CGPoint(x: bounds.minX + result.positions[index].x,
                            y: bounds.minY + result.positions[index].y),
                proposal: .unspecified
            )
        }
    }

    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []

        init(in width: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var lineHeight: CGFloat = 0

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)

                if x + size.width > width, x > 0 {
                    x = 0
                    y += lineHeight + spacing
                    lineHeight = 0
                }

                positions.append(CGPoint(x: x, y: y))
                lineHeight = max(lineHeight, size.height)
                x += size.width + spacing
            }

            self.size = CGSize(width: width, height: y + lineHeight)
        }
    }
}
