import Foundation
import SwiftUI

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var speechVolume: Float
    @Published var speechRate: Float
    @Published var tutorialEnabled: Bool
    @Published var hapticEnabled: Bool
    @Published var defaultSpread: TarotSpread

    private let settingsManager = SettingsManager.shared

    init() {
        speechVolume = settingsManager.speechVolume
        speechRate = settingsManager.speechRate
        tutorialEnabled = settingsManager.tutorialEnabled
        hapticEnabled = settingsManager.hapticEnabled
        defaultSpread = settingsManager.defaultSpread
    }

    func updateSpeechVolume(_ value: Float) {
        speechVolume = value
        settingsManager.speechVolume = value
        SpeechService.shared.speak("Volume test")
    }

    func updateSpeechRate(_ value: Float) {
        speechRate = value
        settingsManager.speechRate = value
        SpeechService.shared.speak("Speed test")
    }

    func toggleTutorial() {
        tutorialEnabled.toggle()
        settingsManager.tutorialEnabled = tutorialEnabled
        HapticService.shared.selection()
        let status = tutorialEnabled ? "on" : "off"
        SpeechService.shared.speak("Tutorial \(status)")
    }

    func toggleHaptic() {
        hapticEnabled.toggle()
        settingsManager.hapticEnabled = hapticEnabled
        if hapticEnabled {
            HapticService.shared.success()
        }
        let status = hapticEnabled ? "on" : "off"
        SpeechService.shared.speak("Haptic feedback \(status)")
    }

    func setDefaultSpread(_ spread: TarotSpread) {
        defaultSpread = spread
        settingsManager.defaultSpread = spread
        HapticService.shared.selection()
        SpeechService.shared.speak("Default spread: \(spread.name)")
    }

    func resetTutorials() {
        settingsManager.settings.homeTutorialShown = false
        settingsManager.settings.logsTutorialShown = false
        settingsManager.settings.settingsTutorialShown = false
        HapticService.shared.success()
        SpeechService.shared.speak("Tutorials reset")
    }

    func resetAllSettings() {
        settingsManager.resetToDefaults()

        speechVolume = settingsManager.speechVolume
        speechRate = settingsManager.speechRate
        tutorialEnabled = settingsManager.tutorialEnabled
        hapticEnabled = settingsManager.hapticEnabled
        defaultSpread = settingsManager.defaultSpread

        HapticService.shared.success()
        SpeechService.shared.speak("All settings reset")
    }
}
