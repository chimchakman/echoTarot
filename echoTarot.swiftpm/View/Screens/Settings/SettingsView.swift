import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @ObservedObject private var hashtagManager = HashtagManager.shared
    @State private var showResetAlert = false
    @State private var showHashtagSheet = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("설정")
                    .font(.title)
                    .fontWeight(.heavy)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)

                settingsSection(title: "음성") {
                    VolumeSettingView(viewModel: viewModel)
                }

                settingsSection(title: "튜토리얼") {
                    TutorialSettingsView(viewModel: viewModel)
                }

                settingsSection(title: "기본 스프레드") {
                    SpreadSettingsView(viewModel: viewModel)
                }

                settingsSection(title: "해시태그 관리") {
                    Button(action: { showHashtagSheet = true }) {
                        HStack {
                            Label("해시태그 관리", systemImage: "tag")
                            Spacer()
                            Text("\(hashtagManager.hashtags.count)개")
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
                    .accessibilityLabel("해시태그 관리, \(hashtagManager.hashtags.count)개")
                    .accessibilityHint("탭하여 해시태그 목록을 관리합니다")
                }

                settingsSection(title: "피드백") {
                    Toggle(isOn: Binding(
                        get: { viewModel.hapticEnabled },
                        set: { _ in viewModel.toggleHaptic() }
                    )) {
                        Label("햅틱 피드백", systemImage: "hand.tap")
                    }
                    .tint(.indigo)
                    .padding()
                    .background(Color.black.opacity(0.5))
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .accessibilityLabel("햅틱 피드백")
                    .accessibilityValue(viewModel.hapticEnabled ? "켜짐" : "꺼짐")
                }

                settingsSection(title: "초기화") {
                    VStack(spacing: 12) {
                        Button(action: {
                            viewModel.resetTutorials()
                        }) {
                            HStack {
                                Label("튜토리얼 초기화", systemImage: "arrow.counterclockwise")
                                Spacer()
                            }
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.5))
                            .cornerRadius(12)
                        }
                        .accessibilityHint("튜토리얼을 다시 볼 수 있습니다")

                        Button(action: {
                            showResetAlert = true
                        }) {
                            HStack {
                                Label("모든 설정 초기화", systemImage: "trash")
                                Spacer()
                            }
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.red.opacity(0.5))
                            .cornerRadius(12)
                        }
                        .accessibilityHint("모든 설정을 기본값으로 되돌립니다")
                    }
                }

                VStack(spacing: 8) {
                    Text("에코 타로")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.6))
                    Text("버전 1.0")
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
        .alert("설정 초기화", isPresented: $showResetAlert) {
            Button("취소", role: .cancel) {}
            Button("초기화", role: .destructive) {
                viewModel.resetAllSettings()
            }
        } message: {
            Text("모든 설정을 기본값으로 되돌리시겠습니까?")
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
