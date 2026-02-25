import SwiftUI

struct TutorialSettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel

    var body: some View {
        VStack(spacing: 12) {
            Toggle(isOn: Binding(
                get: { viewModel.tutorialEnabled },
                set: { _ in viewModel.toggleTutorial() }
            )) {
                Label("튜토리얼 활성화", systemImage: "questionmark.circle")
            }
            .tint(.indigo)
            .padding()
            .background(Color.black.opacity(0.5))
            .foregroundColor(.white)
            .cornerRadius(12)
            .accessibilityLabel("튜토리얼 활성화")
            .accessibilityValue(viewModel.tutorialEnabled ? "켜짐" : "꺼짐")
            .accessibilityHint("각 화면 첫 방문 시 튜토리얼을 표시합니다")

            if viewModel.tutorialEnabled {
                Text("각 화면을 처음 방문할 때 사용법을 안내합니다")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 4)
            }
        }
    }
}
