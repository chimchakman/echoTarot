import SwiftUI
import UIKit

struct CardReadingsListView: View {
    let card: TarotCard
    @ObservedObject var viewModel: LogsViewModel
    @ObservedObject private var settingsManager = SettingsManager.shared
    @State private var selectedReading: (any ReadingProtocol)?
    @State private var isEditingKeywords = false
    @State private var showAddUprightSheet = false
    @State private var showAddReversedSheet = false
    @State private var newKeywordText = ""
    @State private var showResetAlert = false
    @Environment(\.dismiss) private var dismiss

    private var customization: CardKeywordCustomization {
        settingsManager.customization(for: card.id)
    }

    private var baseUprightKeywords: [String] {
        card.uprightMeaning
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
    }

    private var baseReversedKeywords: [String] {
        card.reversedMeaning
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
    }

    private var effectiveUprightKeywords: [(keyword: String, isUserAdded: Bool)] {
        let base = baseUprightKeywords
            .filter { !customization.removedUpright.contains($0) }
            .map { (keyword: $0, isUserAdded: false) }
        let added = customization.addedUpright.map { (keyword: $0, isUserAdded: true) }
        return base + added
    }

    private var effectiveReversedKeywords: [(keyword: String, isUserAdded: Bool)] {
        let base = baseReversedKeywords
            .filter { !customization.removedReversed.contains($0) }
            .map { (keyword: $0, isUserAdded: false) }
        let added = customization.addedReversed.map { (keyword: $0, isUserAdded: true) }
        return base + added
    }

    private var readings: [any ReadingProtocol] {
        viewModel.getReadings(for: card.id)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    cardHeaderSection
                    keywordsSection
                    Divider()
                    readingsSection
                }
                .padding(.bottom, 40)
            }
            .navigationTitle(card.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(isEditingKeywords ? "Done" : "Edit") {
                        isEditingKeywords.toggle()
                        let message = isEditingKeywords ? "Keyword edit mode" : "Keyword editing complete"
                        if #available(iOS 17.0, *) {
                            AccessibilityNotification.Announcement(message).post()
                        }
                    }
                    .accessibilityLabel(isEditingKeywords ? "Done editing keywords" : "Edit keywords")
                    .accessibilityHint(isEditingKeywords ? "Exit edit mode" : "Add or remove keywords")
                }
            }
            .sheet(item: Binding(
                get: { selectedReading.map { AnyReadingWrapper(reading: $0) } },
                set: { selectedReading = $0?.reading }
            )) { wrapper in
                ReadingDetailView(reading: wrapper.reading, viewModel: viewModel)
            }
            .sheet(isPresented: $showAddUprightSheet) {
                addKeywordSheet(isUpright: true)
            }
            .sheet(isPresented: $showAddReversedSheet) {
                addKeywordSheet(isUpright: false)
            }
            .onAppear {
                if !UIAccessibility.isVoiceOverRunning {
                    let count = readings.count
                    if count > 0 {
                        SpeechService.shared.speak("\(count) reading\(count == 1 ? "" : "s") containing \(card.name)")
                    } else {
                        SpeechService.shared.speak("No readings containing \(card.name)")
                    }
                }
                HapticService.shared.tap()
            }
        }
    }

    // MARK: - Card Header

    private var cardHeaderSection: some View {
        VStack(spacing: 12) {
            Image(card.imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 260)
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.4), radius: 12, x: 0, y: 6)
                .accessibilityHidden(true)

            Text(card.name)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .accessibilityLabel("\(card.name), \(card.suit.name)")

            Text(card.suit.name)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .accessibilityHidden(true)

            CardImageDescriptionButton(cardId: card.id)
        }
        .padding(.top, 16)
    }

    // MARK: - Keywords Section

    private var keywordsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            keywordGroup(
                title: "Upright",
                keywords: effectiveUprightKeywords,
                accessibilityLabel: "Upright keywords: \(effectiveUprightKeywords.map(\.keyword).joined(separator: ", "))",
                onAdd: { showAddUprightSheet = true },
                onDelete: { keyword in
                    settingsManager.removeUprightKeyword(keyword, for: card.id, baseKeywords: baseUprightKeywords)
                    if #available(iOS 17.0, *) {
                            AccessibilityNotification.Announcement("Upright keyword \(keyword) removed").post()
                        }
                    HapticService.shared.tap()
                }
            )

            keywordGroup(
                title: "Reversed",
                keywords: effectiveReversedKeywords,
                accessibilityLabel: "Reversed keywords: \(effectiveReversedKeywords.map(\.keyword).joined(separator: ", "))",
                onAdd: { showAddReversedSheet = true },
                onDelete: { keyword in
                    settingsManager.removeReversedKeyword(keyword, for: card.id, baseKeywords: baseReversedKeywords)
                    if #available(iOS 17.0, *) {
                            AccessibilityNotification.Announcement("Reversed keyword \(keyword) removed").post()
                        }
                    HapticService.shared.tap()
                }
            )

            if isEditingKeywords && !customization.isEmpty {
                Button(role: .destructive) {
                    showResetAlert = true
                } label: {
                    Label("Reset to defaults", systemImage: "arrow.counterclockwise")
                }
                .padding(.top, 8)
                .accessibilityLabel("Reset keywords to defaults")
                .accessibilityHint("Revert all keyword changes for this card")
            }
        }
        .padding(.horizontal)
        .alert("Reset Keywords", isPresented: $showResetAlert) {
            Button("Reset", role: .destructive) {
                settingsManager.resetKeywords(for: card.id)
                HapticService.shared.impact(.medium)
                if #available(iOS 17.0, *) {
                    AccessibilityNotification.Announcement("Keywords reset to defaults").post()
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("All keyword changes for this card will be removed. Continue?")
        }
    }

    private func keywordGroup(
        title: String,
        keywords: [(keyword: String, isUserAdded: Bool)],
        accessibilityLabel: String,
        onAdd: @escaping () -> Void,
        onDelete: @escaping (String) -> Void
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)

                Spacer()

                if isEditingKeywords {
                    Button {
                        onAdd()
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.indigo)
                            .font(.title3)
                    }
                    .accessibilityLabel("Add \(title) keyword")
                }
            }

            if keywords.isEmpty {
                Text("No keywords")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .accessibilityLabel("No \(title) keywords")
            } else {
                FlowLayout(spacing: 8) {
                    ForEach(keywords, id: \.keyword) { item in
                        KeywordChipView(
                            keyword: item.keyword,
                            isEditing: isEditingKeywords,
                            isUserAdded: item.isUserAdded,
                            onDelete: { onDelete(item.keyword) }
                        )
                        .foregroundColor(.primary)
                    }
                }
                .accessibilityElement(children: .contain)
                .accessibilityLabel(accessibilityLabel)
            }
        }
    }

    // MARK: - Readings Section

    private var readingsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Reading History")
                    .font(.headline)
                    .foregroundColor(.primary)

                Spacer()

                Text("\(readings.count)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)

            if readings.isEmpty {
                VStack(spacing: 12) {
                    Text("No readings contain this card yet")
                        .font(.body)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)

                    Text("Start a new reading from the Home screen")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
                .padding(.horizontal)
                .accessibilityElement(children: .combine)
                .accessibilityLabel("No readings contain this card. Start a new reading from the Home screen.")
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(readings, id: \.id) { reading in
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
                .padding(.horizontal)
            }
        }
    }

    // MARK: - Add Keyword Sheet

    private func addKeywordSheet(isUpright: Bool) -> some View {
        NavigationStack {
            VStack(spacing: 20) {
                TextField(isUpright ? "Enter upright keyword" : "Enter reversed keyword", text: $newKeywordText)
                    .textFieldStyle(.roundedBorder)
                    .padding()
                    .onSubmit {
                        submitNewKeyword(isUpright: isUpright)
                    }

                Spacer()
            }
            .navigationTitle(isUpright ? "Add Upright Keyword" : "Add Reversed Keyword")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        newKeywordText = ""
                        if isUpright { showAddUprightSheet = false }
                        else { showAddReversedSheet = false }
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add") {
                        submitNewKeyword(isUpright: isUpright)
                    }
                    .disabled(newKeywordText.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .presentationDetents([.medium])
        }
    }

    private func submitNewKeyword(isUpright: Bool) {
        let trimmed = newKeywordText.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }

        if isUpright {
            settingsManager.addUprightKeyword(trimmed, for: card.id)
            showAddUprightSheet = false
        } else {
            settingsManager.addReversedKeyword(trimmed, for: card.id)
            showAddReversedSheet = false
        }

        let direction = isUpright ? "Upright" : "Reversed"
        if #available(iOS 17.0, *) {
            AccessibilityNotification.Announcement("\(direction) keyword \(trimmed) added").post()
        }
        HapticService.shared.tap()
        newKeywordText = ""
    }
}
