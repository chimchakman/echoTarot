import SwiftUI

struct CardReadingsListView: View {
    let card: TarotCard
    @ObservedObject var viewModel: LogsViewModel
    @State private var selectedReading: (any ReadingProtocol)?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if readings.isEmpty {
                    emptyStateView
                } else {
                    readingsList
                }
            }
            .navigationTitle(card.koreanName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("닫기") {
                        dismiss()
                    }
                }
            }
            .sheet(item: Binding(
                get: { selectedReading.map { AnyReadingWrapper(reading: $0) } },
                set: { selectedReading = $0?.reading }
            )) { wrapper in
                ReadingDetailView(reading: wrapper.reading, viewModel: viewModel)
            }
            .onAppear {
                let count = readings.count
                if count > 0 {
                    SpeechService.shared.speak("\(card.koreanName) 카드가 포함된 리딩 \(count)개")
                } else {
                    SpeechService.shared.speak("\(card.koreanName) 카드가 포함된 리딩이 없습니다")
                }
                HapticService.shared.tap()
            }
        }
    }

    private var readings: [any ReadingProtocol] {
        viewModel.getReadings(for: card.id)
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Spacer()

            Image(card.imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 200)
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                .accessibilityHidden(true)

            Text("이 카드가 포함된 리딩이 없습니다")
                .font(.title3)
                .foregroundColor(.white.opacity(0.6))
                .multilineTextAlignment(.center)

            Text("홈 화면에서 새로운 리딩을 시작해보세요")
                .font(.body)
                .foregroundColor(.white.opacity(0.4))
                .multilineTextAlignment(.center)

            Spacer()
        }
        .padding()
        .accessibilityElement(children: .combine)
        .accessibilityLabel("이 카드가 포함된 리딩이 없습니다. 홈 화면에서 새로운 리딩을 시작해보세요.")
    }

    private var readingsList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(readings, id: \.id) { reading in
                    ReadingRowView(reading: reading, viewModel: viewModel)
                        .onTapGesture {
                            HapticService.shared.tap()
                            selectedReading = reading
                        }
                }
            }
            .padding()
            .padding(.bottom, 100)
        }
    }
}
