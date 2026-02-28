import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @ObservedObject private var hashtagManager = HashtagManager.shared
    @State private var showHashtagSheet = false
    @AccessibilityFocusState private var isTitleFocused: Bool

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("Settings")
                    .font(.title)
                    .fontWeight(.heavy)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .accessibilityFocused($isTitleFocused)

                settingsSection(title: "Voice") {
                    VolumeSettingView(viewModel: viewModel)
                }

                settingsSection(title: "Default Spread") {
                    SpreadSettingsView(viewModel: viewModel)
                }

                settingsSection(title: "Hashtag Management") {
                    Button(action: { showHashtagSheet = true }) {
                        HStack {
                            Label("Manage Hashtags", systemImage: "tag")
                            Spacer()
                            Text("\(hashtagManager.hashtags.count)")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.6))
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.4))
                        }
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.black.opacity(0.5))
                        .cornerRadius(12)
                    }
                    .accessibilityLabel("Manage hashtags, \(hashtagManager.hashtags.count) items")
                    .accessibilityHint("Tap to manage your hashtag list")
                }

                settingsSection(title: "Feedback") {
                    Toggle(isOn: Binding(
                        get: { viewModel.hapticEnabled },
                        set: { _ in viewModel.toggleHaptic() }
                    )) {
                        Label("Haptic Feedback", systemImage: "hand.tap")
                    }
                    .tint(.indigo)
                    .padding()
                    .background(Color.black.opacity(0.5))
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .accessibilityLabel("Haptic feedback")
                    .accessibilityValue(viewModel.hapticEnabled ? "on" : "off")
                }

                VStack(spacing: 8) {
                    Text("Echo Tarot")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.6))
                    Text("Version 1.0")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.4))
                }
                .padding(.top, 32)
                .padding(.bottom, 100)
            }
            .padding(.vertical)
        }
        .sheet(isPresented: $showHashtagSheet) {
            HashtagSettingsView()
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isTitleFocused = true
            }
        }
    }

    private func settingsSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .fontWeight(.heavy)
                .foregroundColor(.white.opacity(0.8))
                .padding(.horizontal)

            content()
                .padding(.horizontal)
        }
    }
}
