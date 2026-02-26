import SwiftUI

struct HashtagSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var hashtagManager = HashtagManager.shared
    @State private var showingRenameSheet = false
    @State private var showingDeleteAlert = false
    @State private var selectedHashtag: String = ""
    @State private var renameText = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    if hashtagManager.hashtags.isEmpty {
                        Text("저장된 태그가 없습니다")
                            .font(.body)
                            .foregroundColor(.white.opacity(0.5))
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.black.opacity(0.3))
                            .cornerRadius(12)
                            .accessibilityLabel("저장된 태그가 없습니다")
                    } else {
                        ForEach(hashtagManager.hashtags, id: \.self) { hashtag in
                            hashtagRow(hashtag)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("해시태그 관리")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("완료") {
                        dismiss()
                    }
                    .accessibilityLabel("해시태그 관리 닫기")
                }
            }
        }
        .sheet(isPresented: $showingRenameSheet) {
            renameSheet
        }
        .alert("태그 삭제", isPresented: $showingDeleteAlert) {
            Button("취소", role: .cancel) {}
            Button("삭제", role: .destructive) {
                performDelete(selectedHashtag)
            }
        } message: {
            Text("'\(selectedHashtag)' 태그를 삭제하시겠습니까? 모든 기록에서 제거됩니다.")
        }
    }

    private func hashtagRow(_ hashtag: String) -> some View {
        HStack {
            Text("#\(hashtag)")
                .font(.body)
                .foregroundColor(.white)

            Spacer()

            Button(action: {
                selectedHashtag = hashtag
                renameText = hashtag
                showingRenameSheet = true
                HapticService.shared.tap()
            }) {
                Image(systemName: "pencil.circle")
                    .foregroundColor(.indigo)
                    .font(.title2)
            }
            .accessibilityLabel("\(hashtag) 이름 변경")
            .accessibilityHint("탭하여 태그 이름을 변경합니다")

            Button(action: {
                selectedHashtag = hashtag
                showingDeleteAlert = true
                HapticService.shared.tap()
            }) {
                Image(systemName: "trash.circle")
                    .foregroundColor(.red.opacity(0.8))
                    .font(.title2)
            }
            .accessibilityLabel("\(hashtag) 삭제")
            .accessibilityHint("탭하여 태그를 삭제합니다")
        }
        .padding()
        .background(Color.black.opacity(0.5))
        .cornerRadius(12)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("태그 \(hashtag)")
    }

    private var renameSheet: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("'\(selectedHashtag)' 태그 이름 변경")
                    .font(.headline)
                    .foregroundColor(.primary)
                    .accessibilityLabel("태그 이름 변경 화면")

                TextField("새 태그 이름", text: $renameText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .accessibilityLabel("새 태그 이름 입력 필드")

                Spacer()
            }
            .padding()
            .navigationTitle("이름 변경")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") {
                        showingRenameSheet = false
                    }
                    .accessibilityLabel("이름 변경 취소")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("확인") {
                        performRename(from: selectedHashtag, to: renameText)
                        showingRenameSheet = false
                    }
                    .disabled(renameText.trimmingCharacters(in: .whitespaces).isEmpty)
                    .accessibilityLabel("이름 변경 확인")
                    .accessibilityHint("탭하여 새 이름으로 변경합니다")
                }
            }
        }
        .presentationDetents([.medium])
    }

    private func performRename(from oldName: String, to newName: String) {
        let trimmed = newName.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty, trimmed != oldName else { return }

        // Update master list first
        HashtagManager.shared.rename(from: oldName, to: trimmed)

        // Update all readings
        do {
            try PersistenceManager.shared.renameHashtag(from: oldName, to: trimmed)
            HapticService.shared.success()
            SpeechService.shared.speak("\(trimmed)으로 변경되었습니다")
            if #available(iOS 17.0, *) {
                AccessibilityNotification.Announcement("\(trimmed)으로 변경되었습니다").post()
            }
        } catch {
            // Rollback master list on failure
            HashtagManager.shared.rename(from: trimmed, to: oldName)
            HapticService.shared.error()
            SpeechService.shared.speak("이름 변경에 실패했습니다")
        }
    }

    private func performDelete(_ hashtag: String) {
        // Remove from master list first
        HashtagManager.shared.remove(hashtag)

        // Remove from all readings
        do {
            try PersistenceManager.shared.deleteHashtag(hashtag)
            HapticService.shared.success()
            SpeechService.shared.speak("태그가 삭제되었습니다")
            if #available(iOS 17.0, *) {
                AccessibilityNotification.Announcement("태그가 삭제되었습니다").post()
            }
        } catch {
            // Rollback master list on failure
            HashtagManager.shared.add(hashtag)
            HapticService.shared.error()
            SpeechService.shared.speak("삭제에 실패했습니다")
        }
    }
}
