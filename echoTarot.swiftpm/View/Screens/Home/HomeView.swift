import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @StateObject private var settingsManager = SettingsManager.shared
    @State private var showingCancelAlert = false

    var body: some View {
        ZStack {
            switch viewModel.state {
            case .idle:
                IdleStateView(viewModel: viewModel)
            case .questionRecording:
                QuestionRecordingView(viewModel: viewModel)
            case .hashtagInput:
                HashtagInputView(viewModel: viewModel)
            case .cardDrawing:
                CardDrawingView(viewModel: viewModel)
            case .cardRevealed:
                CardRevealedView(viewModel: viewModel)
            case .readingRecording:
                ReadingRecordingView(viewModel: viewModel)
            case .complete:
                ReadingCompleteView(viewModel: viewModel)
            }

            if viewModel.state != .idle && viewModel.state != .complete {
                VStack {
                    HStack {
                        Button("Cancel") {
                            showingCancelAlert = true
                        }
                        .font(.body)
                        .foregroundColor(.white)
                        .padding(.horizontal, 25)
                        .padding(.top, 10)
                        .accessibilityLabel("Cancel reading")
                        .accessibilityHint("Cancel the current reading and return to the start")
                        .accessibilitySortPriority(-1)
                        Spacer()
                    }
                    Spacer()
                }
                .zIndex(100)
                .allowsHitTesting(true)
            }
        }
        .alert("Cancel this reading?", isPresented: $showingCancelAlert) {
            Button("Continue", role: .cancel) {}
            Button("Cancel reading", role: .destructive) {
                viewModel.cancelReading()
            }
        } message: {
            Text("The current reading will not be saved and you will return to the start.")
        }
        .onAppear {
            if settingsManager.shouldShowTutorial(for: "home") {
                // Tutorial handled via TutorialManager
            }
        }
    }
}
