import SwiftUI
import UIKit

struct HashtagInputView: View {
    @ObservedObject var viewModel: HomeViewModel
    @State private var existingHashtags: [String] = []
    @State private var selectedHashtags: Set<String> = []
    @State private var showingNewTagInput = false
    @State private var newTagText = ""

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            Text("Select tags")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .accessibilityLabel("Tag selection screen")

            Text("Select a previously used tag or add a new one")
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(.white.opacity(0.8))
                .accessibilityLabel("Select a previous tag or add a new one")

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
                        if showingNewTagInput && !UIAccessibility.isVoiceOverRunning {
                            SpeechService.shared.speak("New tag input field opened")
                        }
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Add new tag")
                        }
                        .font(.body)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white.opacity(0.3))
                        .cornerRadius(12)
                    }
                    .accessibilityLabel("Add new tag button")
                    .accessibilityHint("Tap to enter a new tag")

                    // New tag input field
                    if showingNewTagInput {
                        HStack {
                            TextField("Enter tag", text: $newTagText)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .accessibilityLabel("New tag input field")

                            Button(action: addNewTag) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                    .font(.title2)
                            }
                            .accessibilityLabel("Confirm add tag")
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
                    if !UIAccessibility.isVoiceOverRunning {
                        SpeechService.shared.speak("Skipping tag selection")
                    }
                    viewModel.skipHashtagInput()
                }) {
                    Text("Skip")
                        .font(.body)
                        .foregroundColor(.white.opacity(0.6))
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                }
                .accessibilityLabel("Skip tag selection")
                .accessibilityHint("Continue without selecting tags")

                Button(action: {
                    HapticService.shared.success()
                    if !UIAccessibility.isVoiceOverRunning {
                        let count = selectedHashtags.count
                        SpeechService.shared.speak("\(count) tag\(count == 1 ? "" : "s") selected")
                    }
                    viewModel.completeHashtagInput(selectedHashtags: Array(selectedHashtags))
                }) {
                    Text("Done")
                        .font(.body)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 12)
                        .background(Color.blue.opacity(0.6))
                        .cornerRadius(12)
                }
                .accessibilityLabel("Done selecting tags")
                .accessibilityHint("\(selectedHashtags.count) tag\(selectedHashtags.count == 1 ? "" : "s") selected. Tap to continue")
            }
            .padding(.bottom, 100)
        }
        .padding()
        .onAppear {
            loadExistingHashtags()
            if !UIAccessibility.isVoiceOverRunning {
                SpeechService.shared.speak("Tag selection screen. You can select or add tags.")
            }
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
            .background(isSelected ? Color.blue.opacity(0.4) : Color.white.opacity(0.3))
            .cornerRadius(12)
        }
        .accessibilityLabel("Tag: \(hashtag)")
        .accessibilityHint(isSelected ? "Selected. Tap to deselect" : "Not selected. Tap to select")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private func toggleHashtag(_ hashtag: String) {
        HapticService.shared.selection()
        if selectedHashtags.contains(hashtag) {
            selectedHashtags.remove(hashtag)
            if !UIAccessibility.isVoiceOverRunning {
                SpeechService.shared.speak("\(hashtag) deselected")
            }
        } else {
            selectedHashtags.insert(hashtag)
            if !UIAccessibility.isVoiceOverRunning {
                SpeechService.shared.speak("\(hashtag) selected")
            }
        }
    }

    private func addNewTag() {
        let trimmed = newTagText.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }

        // Check for duplicates
        if existingHashtags.contains(trimmed) {
            HapticService.shared.warning()
            if !UIAccessibility.isVoiceOverRunning {
                SpeechService.shared.speak("This tag already exists")
            }
            return
        }

        // Persist to master list
        HashtagManager.shared.add(trimmed)

        // Add to existing and select it
        existingHashtags.insert(trimmed, at: 0)
        selectedHashtags.insert(trimmed)

        HapticService.shared.success()
        if !UIAccessibility.isVoiceOverRunning {
            SpeechService.shared.speak("\(trimmed) tag added and selected")
        }

        // Reset input
        newTagText = ""
        showingNewTagInput = false
    }

    private func loadExistingHashtags() {
        // Load master list from HashtagManager
        var tags = Set(HashtagManager.shared.hashtags)

        // Merge tags from readings for backward compatibility
        if let readings = try? PersistenceManager.shared.fetchAllReadings() {
            let readingTags = readings.flatMap { $0.hashtags }
            tags.formUnion(readingTags)
            // Persist any new tags found in readings back to master list
            HashtagManager.shared.mergeFromReadings(readingTags)
        }

        existingHashtags = Array(tags).sorted()
    }
}
