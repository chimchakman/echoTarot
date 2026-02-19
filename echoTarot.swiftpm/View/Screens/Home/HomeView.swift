import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @StateObject private var settingsManager = SettingsManager.shared

    var body: some View {
        ZStack {
            switch viewModel.state {
            case .idle:
                IdleStateView(viewModel: viewModel)
            case .questionRecording:
                QuestionRecordingView(viewModel: viewModel)
            case .cardDrawing:
                CardDrawingView(viewModel: viewModel)
            case .cardRevealed:
                CardRevealedView(viewModel: viewModel)
            case .readingRecording:
                ReadingRecordingView(viewModel: viewModel)
            case .complete:
                ReadingCompleteView(viewModel: viewModel)
            }
        }
        .onAppear {
            if settingsManager.shouldShowTutorial(for: "home") {
                // Tutorial handled via TutorialManager
            }
        }
    }
}
