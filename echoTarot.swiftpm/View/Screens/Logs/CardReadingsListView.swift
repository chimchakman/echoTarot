import SwiftUI

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
            .navigationTitle(card.koreanName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("닫기") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(isEditingKeywords ? "완료" : "편집") {
                        isEditingKeywords.toggle()
                        let message = isEditingKeywords ? "키워드 편집 모드" : "키워드 편집 완료"
                        if #available(iOS 17.0, *) {
                            AccessibilityNotification.Announcement(message).post()
                        }
                    }
                    .accessibilityLabel(isEditingKeywords ? "키워드 편집 완료" : "키워드 편집")
                    .accessibilityHint(isEditingKeywords ? "편집 모드를 종료합니다" : "키워드를 추가하거나 삭제합니다")
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

            Text(card.koreanName)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)

            Text(card.suit.koreanName)
                .font(.subheadline)
                .foregroundColor(.secondary)

            CardImageDescriptionButton(card: card)
        }
        .padding(.top, 16)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("\(card.koreanName), \(card.suit.koreanName)")
    }

    // MARK: - Keywords Section

    private var keywordsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            keywordGroup(
                title: "정방향",
                keywords: effectiveUprightKeywords,
                accessibilityLabel: "정방향 키워드: \(effectiveUprightKeywords.map(\.keyword).joined(separator: ", "))",
                onAdd: { showAddUprightSheet = true },
                onDelete: { keyword in
                    settingsManager.removeUprightKeyword(keyword, for: card.id, baseKeywords: baseUprightKeywords)
                    if #available(iOS 17.0, *) {
                            AccessibilityNotification.Announcement("정방향 키워드 \(keyword) 삭제됨").post()
                        }
                    HapticService.shared.tap()
                }
            )

            keywordGroup(
                title: "역방향",
                keywords: effectiveReversedKeywords,
                accessibilityLabel: "역방향 키워드: \(effectiveReversedKeywords.map(\.keyword).joined(separator: ", "))",
                onAdd: { showAddReversedSheet = true },
                onDelete: { keyword in
                    settingsManager.removeReversedKeyword(keyword, for: card.id, baseKeywords: baseReversedKeywords)
                    if #available(iOS 17.0, *) {
                            AccessibilityNotification.Announcement("역방향 키워드 \(keyword) 삭제됨").post()
                        }
                    HapticService.shared.tap()
                }
            )

            if isEditingKeywords && !customization.isEmpty {
                Button(role: .destructive) {
                    showResetAlert = true
                } label: {
                    Label("기본값으로 초기화", systemImage: "arrow.counterclockwise")
                }
                .padding(.top, 8)
                .accessibilityLabel("키워드 기본값으로 초기화")
                .accessibilityHint("이 카드의 모든 키워드 변경사항을 되돌립니다")
            }
        }
        .padding(.horizontal)
        .alert("키워드 초기화", isPresented: $showResetAlert) {
            Button("초기화", role: .destructive) {
                settingsManager.resetKeywords(for: card.id)
                HapticService.shared.impact(.medium)
                if #available(iOS 17.0, *) {
                    AccessibilityNotification.Announcement("키워드가 기본값으로 초기화되었습니다").post()
                }
            }
            Button("취소", role: .cancel) {}
        } message: {
            Text("이 카드의 모든 키워드 변경사항이 삭제됩니다. 계속하시겠습니까?")
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
                    .accessibilityLabel("\(title) 키워드 추가")
                }
            }

            if keywords.isEmpty {
                Text("키워드 없음")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .accessibilityLabel("\(title) 키워드 없음")
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
                Text("리딩 기록")
                    .font(.headline)
                    .foregroundColor(.primary)

                Spacer()

                Text("\(readings.count)개")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)

            if readings.isEmpty {
                VStack(spacing: 12) {
                    Text("이 카드가 포함된 리딩이 없습니다")
                        .font(.body)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)

                    Text("홈 화면에서 새로운 리딩을 시작해보세요")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
                .padding(.horizontal)
                .accessibilityElement(children: .combine)
                .accessibilityLabel("이 카드가 포함된 리딩이 없습니다. 홈 화면에서 새로운 리딩을 시작해보세요.")
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(readings, id: \.id) { reading in
                        ReadingRowView(reading: reading, viewModel: viewModel)
                            .onTapGesture {
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
                TextField(isUpright ? "정방향 키워드 입력" : "역방향 키워드 입력", text: $newKeywordText)
                    .textFieldStyle(.roundedBorder)
                    .padding()
                    .onSubmit {
                        submitNewKeyword(isUpright: isUpright)
                    }

                Spacer()
            }
            .navigationTitle(isUpright ? "정방향 키워드 추가" : "역방향 키워드 추가")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("취소") {
                        newKeywordText = ""
                        if isUpright { showAddUprightSheet = false }
                        else { showAddReversedSheet = false }
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("추가") {
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

        let direction = isUpright ? "정방향" : "역방향"
        if #available(iOS 17.0, *) {
            AccessibilityNotification.Announcement("\(direction) 키워드 \(trimmed) 추가됨").post()
        }
        HapticService.shared.tap()
        newKeywordText = ""
    }
}
