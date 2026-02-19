import SwiftUI

struct LogsView: View {
    @StateObject private var viewModel = LogsViewModel()
    @State private var selectedReading: (any ReadingProtocol)?
    @State private var showFilterSheet = false

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("리딩 기록")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                Spacer()

                Button(action: {
                    showFilterSheet = true
                    HapticService.shared.tap()
                }) {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                        .font(.title2)
                        .foregroundColor(.white)
                }
                .accessibilityLabel("정렬 및 필터")
            }
            .padding()

            if viewModel.selectedHashtag != nil || viewModel.selectedCardId != nil {
                activeFiltersView
            }

            if viewModel.isLoading {
                Spacer()
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                Spacer()
            } else if viewModel.filteredReadings.isEmpty {
                emptyStateView
            } else {
                readingsList
            }
        }
        .sheet(isPresented: $showFilterSheet) {
            FilterView(viewModel: viewModel)
        }
        .sheet(item: Binding(
            get: { selectedReading.map { AnyReadingWrapper(reading: $0) } },
            set: { selectedReading = $0?.reading }
        )) { wrapper in
            ReadingDetailView(reading: wrapper.reading, viewModel: viewModel)
        }
        .onAppear {
            viewModel.loadReadings()
        }
    }

    private var activeFiltersView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                if let hashtag = viewModel.selectedHashtag {
                    filterChip(text: "#\(hashtag)") {
                        viewModel.filterByHashtag(nil)
                    }
                }

                if let cardId = viewModel.selectedCardId,
                   let card = viewModel.getCard(for: cardId) {
                    filterChip(text: card.koreanName) {
                        viewModel.filterByCard(nil)
                    }
                }

                Button(action: {
                    viewModel.clearFilters()
                }) {
                    Text("모두 해제")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            .padding(.horizontal)
        }
        .padding(.bottom, 8)
    }

    private func filterChip(text: String, onRemove: @escaping () -> Void) -> some View {
        HStack(spacing: 4) {
            Text(text)
                .font(.caption)
                .foregroundColor(.white)

            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.indigo.opacity(0.6))
        .cornerRadius(16)
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Spacer()

            Image(systemName: "book.closed")
                .font(.system(size: 64))
                .foregroundColor(.white.opacity(0.4))

            Text("기록이 없습니다")
                .font(.title2)
                .foregroundColor(.white.opacity(0.6))

            Text("홈 화면에서 첫 리딩을 시작해보세요")
                .font(.body)
                .foregroundColor(.white.opacity(0.4))

            Spacer()
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("기록이 없습니다. 홈 화면에서 첫 리딩을 시작해보세요.")
    }

    private var readingsList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(viewModel.filteredReadings, id: \.id) { reading in
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
// Wrapper to make ReadingProtocol Identifiable for sheet presentation
struct AnyReadingWrapper: Identifiable {
    let id = UUID()
    let reading: any ReadingProtocol
}

