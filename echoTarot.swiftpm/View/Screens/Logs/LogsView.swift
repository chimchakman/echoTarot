import SwiftUI

enum LogsTab {
    case readings
    case dictionary
}

struct LogsView: View {
    @StateObject private var viewModel = LogsViewModel()
    @State private var selectedReading: (any ReadingProtocol)?
    @State private var showFilterSheet = false
    @State private var selectedTab: LogsTab = .readings

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Reading Logs")
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
                .accessibilityLabel("Sort and filter")
            }
            .padding()

            // Custom segmented control with better visibility
            HStack(spacing: 0) {
                segmentButton(
                    title: "Reading List",
                    isSelected: selectedTab == .readings,
                    action: {
                        selectedTab = .readings
                        HapticService.shared.selection()
                        SpeechService.shared.speak("Reading List")
                    }
                )

                segmentButton(
                    title: "Card Dictionary",
                    isSelected: selectedTab == .dictionary,
                    action: {
                        selectedTab = .dictionary
                        HapticService.shared.selection()
                        SpeechService.shared.speak("Card Dictionary")
                    }
                )
            }
            .background(Color.white.opacity(0.15))
            .cornerRadius(10)
            .padding(.horizontal)
            .padding(.bottom, 8)
            .accessibilityLabel("Select view mode")

            if selectedTab == .readings {
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
            } else {
                TarotCardDictionaryView(viewModel: viewModel)
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
                    filterChip(text: card.name) {
                        viewModel.filterByCard(nil)
                    }
                }

                Button(action: {
                    viewModel.clearFilters()
                }) {
                    Text("Clear all")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            .padding(.horizontal)
        }
        .padding(.bottom, 8)
    }

    private func segmentButton(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? .black : .white.opacity(0.9))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(
                    isSelected ? Color.white : Color.black.opacity(0.4)
                )
                .cornerRadius(8)
                .padding(2)
        }
        .accessibilityLabel(title)
        .accessibilityHint(isSelected ? "Selected" : "Tap to select")
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

            Text("No readings yet")
                .font(.title2)
                .foregroundColor(.white.opacity(0.8))

            Text("Start your first reading from the Home screen")
                .font(.body)
                .foregroundColor(.white.opacity(0.6))

            Spacer()
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("No readings yet. Start your first reading from the Home screen.")
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
                        .accessibilityAction(.default) {
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

