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
                        Button("취소") {
                            showingCancelAlert = true
                        }
                        .font(.body)
                        .foregroundColor(.white)
                        .padding(.horizontal, 25)
                        .padding(.top, 10)
                        .accessibilityLabel("리딩 취소")
                        .accessibilityHint("리딩을 취소하고 처음으로 돌아갑니다")
                        .accessibilitySortPriority(-1)
                        Spacer()
                    }
                    Spacer()
                }
                .zIndex(100)
                .allowsHitTesting(true)
            }
        }
        .alert("리딩을 취소하시겠습니까?", isPresented: $showingCancelAlert) {
            Button("계속하기", role: .cancel) {}
            Button("취소", role: .destructive) {
                viewModel.cancelReading()
            }
        } message: {
            Text("현재 리딩이 저장되지 않고 처음으로 돌아갑니다.")
        }
        .onAppear {
            if settingsManager.shouldShowTutorial(for: "home") {
                // Tutorial handled via TutorialManager
            }
        }
    }
}
