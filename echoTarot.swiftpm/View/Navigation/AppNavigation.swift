import SwiftUI

struct AppNavigation: View {
    @StateObject private var navigationState = NavigationState.shared
    @StateObject private var settingsManager = SettingsManager.shared
    @Environment(\.scenePhase) private var scenePhase
    @State private var hasAppearedOnce = false
    @State private var previousScenePhase: ScenePhase = .active

    var body: some View {
        ZStack {
            // Background
            Image("background")
                .resizable()
                .ignoresSafeArea()

            // Main content based on current screen
            Group {
                switch navigationState.currentScreen {
                case .home:
                    HomeView()
                case .logs:
                    LogsView()
                case .settings:
                    SettingsView()
                }
            }
            .transition(.opacity)

            // Page indicator at bottom
            VStack {
                Spacer()
                PageIndicator(
                    totalPages: AppScreen.allCases.count,
                    currentPage: AppScreen.allCases.firstIndex(of: navigationState.currentScreen) ?? 0
                )
            }
        }
        .fullScreenGestures(
            onSwipeLeft: {
                guard !navigationState.isReadingActive else { return }
                navigationState.navigateRight()
            },
            onSwipeRight: {
                guard !navigationState.isReadingActive else { return }
                navigationState.navigateLeft()
            },
            onPinchIn: { navigationState.openSettings() },
            onPinchOut: { navigationState.openTutorial() }
        )
        .sheet(isPresented: $navigationState.showTutorial) {
            TutorialSheet()
        }
        .onAppear {
            guard !hasAppearedOnce else { return }
            hasAppearedOnce = true

            // Skip if tutorial is showing (tutorial handles its own completion announcement)
            guard !TutorialManager.shared.isShowingTutorial else { return }

            // Cold start: announce Home screen intro
            // Use long delay to let VoiceOver finish any automatic focus announcements
            SpeechService.shared.announceAfterDelay(
                "Home. Tap the table button to start today's reading. Swipe left for settings, swipe right for logs.",
                delay: SpeechService.longDelay
            )
        }
        .onChange(of: scenePhase) { newPhase in
            // Re-announce current screen when returning from background
            if newPhase == .active && previousScenePhase == .background && hasAppearedOnce {
                // Skip if tutorial is showing
                guard !TutorialManager.shared.isShowingTutorial else { return }

                SpeechService.shared.announceAfterDelay(
                    navigationState.screenAnnouncement(for: navigationState.currentScreen),
                    delay: SpeechService.mediumDelay
                )
            }
            previousScenePhase = newPhase
        }
    }

}

struct TutorialSheet: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var navigationState = NavigationState.shared

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        tutorialSection(
                            title: "Gesture Guide",
                            items: [
                                ("Tap", "Activate main action"),
                                ("Swipe left", "Next screen (Logs → Home → Settings)"),
                                ("Swipe right", "Previous screen (Settings → Home → Logs)"),
                                ("Swipe up", "Confirm / proceed"),
                                ("Swipe down", "Cancel / go back"),
                                ("Pinch in", "Open Settings"),
                                ("Pinch out", "Open Help")
                            ]
                        )

                        tutorialSection(
                            title: "Screen Guide",
                            items: [
                                ("Home", "Draw tarot cards and record your reading"),
                                ("Logs", "Review your previous reading history"),
                                ("Settings", "Adjust app settings")
                            ]
                        )
                    }
                    .padding()
                }
            }
            .navigationTitle("Help")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func tutorialSection(title: String, items: [(String, String)]) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)

            ForEach(items, id: \.0) { item in
                HStack(alignment: .top) {
                    Text(item.0)
                        .fontWeight(.semibold)
                        .foregroundColor(.indigo)
                        .frame(width: 100, alignment: .leading)

                    Text(item.1)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
        }
    }
}
