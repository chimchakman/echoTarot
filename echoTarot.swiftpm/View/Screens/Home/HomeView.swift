import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @StateObject private var settingsManager = SettingsManager.shared
    @ObservedObject private var navigationState = NavigationState.shared
    @State private var showingCancelAlert = false
    @State private var isTransitioning = false

    var body: some View {
        ZStack {
            switch viewModel.state {
            case .idle:
                IdleStateView(viewModel: viewModel, isTransitioning: $isTransitioning)
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
            // Reset flag in case home was entered in a non-idle state (flag would not be reset by IdleStateView)
            if viewModel.state != .idle {
                navigationState.didNavigateToHome = false
            }
        }
        .onChange(of: viewModel.state) { _ in
            // Signal transition start - prevents old view from setting focus
            isTransitioning = true
            // Reset after SwiftUI animation completes (0.35s typical transition duration)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                isTransitioning = false
            }
        }
    }
}
