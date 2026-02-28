import SwiftUI
import UIKit

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
                        Text("No saved tags")
                            .font(.body)
                            .foregroundColor(.white.opacity(0.5))
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.black.opacity(0.3))
                            .cornerRadius(12)
                            .accessibilityLabel("No saved tags")
                    } else {
                        ForEach(hashtagManager.hashtags, id: \.self) { hashtag in
                            hashtagRow(hashtag)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Manage Hashtags")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .accessibilityLabel("Close hashtag management")
                }
            }
        }
        .sheet(isPresented: $showingRenameSheet) {
            renameSheet
        }
        .alert("Delete Tag", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                performDelete(selectedHashtag)
            }
        } message: {
            Text("Delete the '\(selectedHashtag)' tag? It will be removed from all readings.")
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
            .accessibilityLabel("Rename \(hashtag)")
            .accessibilityHint("Tap to rename this tag")

            Button(action: {
                selectedHashtag = hashtag
                showingDeleteAlert = true
                HapticService.shared.tap()
            }) {
                Image(systemName: "trash.circle")
                    .foregroundColor(.red.opacity(0.8))
                    .font(.title2)
            }
            .accessibilityLabel("Delete \(hashtag)")
            .accessibilityHint("Tap to delete this tag")
        }
        .padding()
        .background(Color.black.opacity(0.5))
        .cornerRadius(12)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Tag: \(hashtag)")
    }

    private var renameSheet: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("Rename '\(selectedHashtag)'")
                    .font(.headline)
                    .foregroundColor(.primary)
                    .accessibilityLabel("Rename tag screen")

                TextField("New tag name", text: $renameText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .accessibilityLabel("New tag name input field")

                Spacer()
            }
            .padding()
            .navigationTitle("Rename")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        showingRenameSheet = false
                    }
                    .accessibilityLabel("Cancel rename")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Confirm") {
                        performRename(from: selectedHashtag, to: renameText)
                        showingRenameSheet = false
                    }
                    .disabled(renameText.trimmingCharacters(in: .whitespaces).isEmpty)
                    .accessibilityLabel("Confirm rename")
                    .accessibilityHint("Tap to apply the new name")
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
            if !UIAccessibility.isVoiceOverRunning {
                SpeechService.shared.speak("Renamed to \(trimmed)")
            }
            if #available(iOS 17.0, *) {
                AccessibilityNotification.Announcement("Renamed to \(trimmed)").post()
            }
        } catch {
            // Rollback master list on failure
            HashtagManager.shared.rename(from: trimmed, to: oldName)
            HapticService.shared.error()
            if !UIAccessibility.isVoiceOverRunning {
                SpeechService.shared.speak("Failed to rename")
            }
        }
    }

    private func performDelete(_ hashtag: String) {
        // Remove from master list first
        HashtagManager.shared.remove(hashtag)

        // Remove from all readings
        do {
            try PersistenceManager.shared.deleteHashtag(hashtag)
            HapticService.shared.success()
            if !UIAccessibility.isVoiceOverRunning {
                SpeechService.shared.speak("Tag deleted")
            }
            if #available(iOS 17.0, *) {
                AccessibilityNotification.Announcement("Tag deleted").post()
            }
        } catch {
            // Rollback master list on failure
            HashtagManager.shared.add(hashtag)
            HapticService.shared.error()
            if !UIAccessibility.isVoiceOverRunning {
                SpeechService.shared.speak("Failed to delete")
            }
        }
    }
}
