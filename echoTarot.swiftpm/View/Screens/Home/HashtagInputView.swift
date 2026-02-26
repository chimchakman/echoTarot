import SwiftUI

struct HashtagInputView: View {
    @ObservedObject var viewModel: HomeViewModel
    @State private var existingHashtags: [String] = []
    @State private var selectedHashtags: Set<String> = []
    @State private var showingNewTagInput = false
    @State private var newTagText = ""

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            Text("태그를 선택하세요")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .accessibilityLabel("태그 선택 화면")

            Text("이전에 사용한 태그를 선택하거나 새로 추가하세요")
                .font(.body)
                .foregroundColor(.white.opacity(0.8))
                .accessibilityLabel("이전 태그 선택 또는 새 태그 추가 가능")

            ScrollView {
                VStack(spacing: 16) {
                    // Existing hashtags grid
                    if !existingHashtags.isEmpty {
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 12) {
                            ForEach(existingHashtags, id: \.self) { hashtag in
                                hashtagButton(hashtag)
                            }
                        }
                    }

                    // New tag button
                    Button(action: {
                        showingNewTagInput.toggle()
                        HapticService.shared.tap()
                        if showingNewTagInput {
                            SpeechService.shared.speak("새 태그 입력창이 열렸습니다")
                        }
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("새 태그 추가")
                        }
                        .font(.body)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(12)
                    }
                    .accessibilityLabel("새 태그 추가 버튼")
                    .accessibilityHint("탭하여 새로운 태그를 입력하세요")

                    // New tag input field
                    if showingNewTagInput {
                        HStack {
                            TextField("태그 입력", text: $newTagText)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .accessibilityLabel("새 태그 입력 필드")

                            Button(action: addNewTag) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                    .font(.title2)
                            }
                            .accessibilityLabel("태그 추가 확인")
                            .disabled(newTagText.trimmingCharacters(in: .whitespaces).isEmpty)
                        }
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal)
            }

            Spacer()

            // Action buttons
            HStack(spacing: 20) {
                Button(action: {
                    HapticService.shared.tap()
                    SpeechService.shared.speak("태그 선택을 건너뜁니다")
                    viewModel.skipHashtagInput()
                }) {
                    Text("건너뛰기")
                        .font(.body)
                        .foregroundColor(.white.opacity(0.6))
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                }
                .accessibilityLabel("태그 선택 건너뛰기")
                .accessibilityHint("태그 없이 계속 진행합니다")

                Button(action: {
                    HapticService.shared.success()
                    let count = selectedHashtags.count
                    SpeechService.shared.speak("\(count)개의 태그가 선택되었습니다")
                    viewModel.completeHashtagInput(selectedHashtags: Array(selectedHashtags))
                }) {
                    Text("완료")
                        .font(.body)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 12)
                        .background(Color.blue.opacity(0.6))
                        .cornerRadius(12)
                }
                .accessibilityLabel("태그 선택 완료")
                .accessibilityHint("\(selectedHashtags.count)개 태그 선택됨. 탭하여 계속 진행")
            }
            .padding(.bottom, 100)
        }
        .padding()
        .onAppear {
            loadExistingHashtags()
            SpeechService.shared.speak("태그 선택 화면입니다. 태그를 선택하거나 새로 추가할 수 있습니다.")
        }
    }

    private func hashtagButton(_ hashtag: String) -> some View {
        let isSelected = selectedHashtags.contains(hashtag)

        return Button(action: {
            toggleHashtag(hashtag)
        }) {
            HStack {
                Text("#\(hashtag)")
                    .font(.body)
                    .foregroundColor(.white)
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(isSelected ? Color.blue.opacity(0.4) : Color.white.opacity(0.2))
            .cornerRadius(12)
        }
        .accessibilityLabel("태그 \(hashtag)")
        .accessibilityHint(isSelected ? "선택됨. 탭하여 선택 해제" : "선택 안 됨. 탭하여 선택")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private func toggleHashtag(_ hashtag: String) {
        HapticService.shared.selection()
        if selectedHashtags.contains(hashtag) {
            selectedHashtags.remove(hashtag)
            SpeechService.shared.speak("\(hashtag) 선택 해제")
        } else {
            selectedHashtags.insert(hashtag)
            SpeechService.shared.speak("\(hashtag) 선택됨")
        }
    }

    private func addNewTag() {
        let trimmed = newTagText.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }

        // Check for duplicates
        if existingHashtags.contains(trimmed) {
            HapticService.shared.warning()
            SpeechService.shared.speak("이미 존재하는 태그입니다")
            return
        }

        // Add to existing and select it
        existingHashtags.insert(trimmed, at: 0)
        selectedHashtags.insert(trimmed)

        HapticService.shared.success()
        SpeechService.shared.speak("\(trimmed) 태그가 추가되고 선택되었습니다")

        // Reset input
        newTagText = ""
        showingNewTagInput = false
    }

    private func loadExistingHashtags() {
        do {
            let readings = try PersistenceManager.shared.fetchAllReadings()
            var uniqueTags = Set<String>()

            for reading in readings {
                uniqueTags.formUnion(reading.hashtags)
            }

            existingHashtags = Array(uniqueTags).sorted()
        } catch {
            existingHashtags = []
        }
    }
}
