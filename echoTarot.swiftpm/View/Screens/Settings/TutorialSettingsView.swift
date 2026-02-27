import SwiftUI

struct TutorialSettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel

    var body: some View {
        VStack(spacing: 12) {
            Toggle(isOn: Binding(
                get: { viewModel.tutorialEnabled },
                set: { _ in viewModel.toggleTutorial() }
            )) {
                Label("Enable Tutorial", systemImage: "questionmark.circle")
            }
            .tint(.indigo)
            .padding()
            .background(Color.black.opacity(0.5))
            .foregroundColor(.white)
            .cornerRadius(12)
            .accessibilityLabel("Enable tutorial")
            .accessibilityValue(viewModel.tutorialEnabled ? "on" : "off")
            .accessibilityHint("Shows a tutorial the first time you visit each screen")

            if viewModel.tutorialEnabled {
                Text("Guides you through each screen on your first visit")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 4)
            }
        }
    }
}
