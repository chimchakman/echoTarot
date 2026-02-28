import Foundation
import SwiftUI

@MainActor
final class TutorialManager: ObservableObject {
    static let shared = TutorialManager()

    @Published var isShowingTutorial = false
    @Published var currentScreen: String?
    @Published var currentScripts: [String] = []

    private let settingsManager = SettingsManager.shared

    private init() {}

    func checkAndShowTutorial(for screen: String) -> Bool {
        guard settingsManager.shouldShowTutorial(for: screen) else {
            return false
        }

        currentScreen = screen
        currentScripts = TutorialScripts.scripts(for: screen)
        isShowingTutorial = true

        return true
    }

    func completeTutorial() {
        if let screen = currentScreen {
            settingsManager.markTutorialShown(for: screen)
        }

        isShowingTutorial = false
        currentScreen = nil
        currentScripts = []

        HapticService.shared.success()
        SpeechService.shared.speakAlways("Tutorial complete.") {
            // Wait for VoiceOver to finish auto-focusing the home screen elements
            // before announcing, so the announcement is not dropped.
            DispatchQueue.main.asyncAfter(deadline: .now() + SpeechService.longDelay) {
                SpeechService.shared.speak(
                    "Home screen. Tap the table button to start today's reading. Swipe left for settings, swipe right for logs."
                )
            }
        }
    }

    func skipTutorial() {
        if let screen = currentScreen {
            settingsManager.markTutorialShown(for: screen)
        }

        isShowingTutorial = false
        currentScreen = nil
        currentScripts = []

        SpeechService.shared.stop()
    }

    func showFirstTimeTutorial() {
        let hasLaunchedBefore = UserDefaults.standard.bool(forKey: "echoTarot.hasLaunchedBefore")

        if !hasLaunchedBefore {
            UserDefaults.standard.set(true, forKey: "echoTarot.hasLaunchedBefore")

            currentScreen = "welcome"
            currentScripts = TutorialScripts.welcomeScripts
            isShowingTutorial = true
        }
    }
}
