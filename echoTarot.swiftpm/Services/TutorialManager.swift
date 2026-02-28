import Foundation
import SwiftUI

@MainActor
final class TutorialManager: ObservableObject {
    static let shared = TutorialManager()

    @Published var isShowingTutorial = false
    @Published var currentScreen: String?
    @Published var currentScripts: [String] = []
    @Published var isPostTutorial = false
    @Published var focusTableButtonAfterTutorial = false

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

        isPostTutorial = true
        isShowingTutorial = false
        currentScreen = nil
        currentScripts = []

        HapticService.shared.success()
        SpeechService.shared.speakAlways("Tutorial complete.") {
            SpeechService.shared.speakAlways(
                "Home. Tap the table button to start today's reading. Swipe left for settings, swipe right for logs."
            ) {
                self.focusTableButtonAfterTutorial = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.isPostTutorial = false
                    self.focusTableButtonAfterTutorial = false
                }
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
