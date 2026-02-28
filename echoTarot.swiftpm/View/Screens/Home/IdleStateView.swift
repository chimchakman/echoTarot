import SwiftUI

struct IdleStateView: View {
    @ObservedObject var viewModel: HomeViewModel
    @Binding var isTransitioning: Bool
    @AccessibilityFocusState private var isTableFocused: Bool
    @ObservedObject private var tutorialManager = TutorialManager.shared
    @ObservedObject private var navigationState = NavigationState.shared

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                
                // Title
                Image("homeText")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .scaledToFit()
                    .frame(maxWidth: 500)
                    .accessibilityLabel("Echo Tarot")
                    .padding(.horizontal, 30)
                    .padding(.top, 65)
                    
                    
                
                Spacer()
            }
            
            VStack {

                Spacer()

                // Table image
                Image("table")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .scaledToFit()
                    .frame(maxHeight: 750)
                    .padding(.horizontal, 20)
                    .padding(.top, 50)
                    .onTapGesture {
                        viewModel.startReading()
                    }
                    .accessibilityLabel("Tarot table")
                    .accessibilityHint("Tap to start a tarot reading")
                    .accessibilityAction(.default) {
                        viewModel.startReading()
                    }
                    .accessibilityFocused($isTableFocused)

                Spacer()


            }
            
            VStack {

                Spacer()

                // Spread selector
                Button(action: {
                    viewModel.changeSpread()
                }) {
                    HStack {
                        Image(systemName: viewModel.selectedSpread == .oneCard ? "1.circle.fill" : "3.circle.fill")
                        Text(viewModel.selectedSpread.name)
                    }
                    .font(.title3)
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.indigo.opacity(0.6))
                    .cornerRadius(20)
                }
                .accessibilityLabel("Spread: \(viewModel.selectedSpread.name)")
                .accessibilityHint("Tap to change")
                .padding(.bottom, 20)


                // Start instruction
                Text("Tap the table to begin")
                    .font(.title2)
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.bottom, 60)
            }
        }
        .onAppear {
            // Guard against setting focus during state transitions or post-tutorial
            guard !isTransitioning && !tutorialManager.isPostTutorial else { return }

            if navigationState.didNavigateToHome && SpeechService.shared.isVoiceOverRunning {
                // Navigated from another screen with VoiceOver on:
                // "Home." announcement fires at mediumDelay (0.5s), lasts ~0.75s
                // Set focus AFTER announcement ends (~1.3s total)
                let focusDelay = SpeechService.mediumDelay + 0.9
                navigationState.didNavigateToHome = false
                DispatchQueue.main.asyncAfter(deadline: .now() + focusDelay) {
                    guard !isTransitioning else { return }
                    isTableFocused = true
                }
            } else {
                // Cold start or VoiceOver off: use short delay as before
                navigationState.didNavigateToHome = false
                DispatchQueue.main.asyncAfter(deadline: .now() + SpeechService.shortDelay) {
                    guard !isTransitioning else { return }
                    isTableFocused = true
                }
            }
        }
        .onChange(of: tutorialManager.focusTableButtonAfterTutorial) { triggered in
            if triggered {
                isTableFocused = true
            }
        }
        .onDisappear {
            // Cancel focus when leaving this view
            isTableFocused = false
        }
    }
}
