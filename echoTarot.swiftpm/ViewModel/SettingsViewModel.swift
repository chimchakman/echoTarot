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
        SpeechService.shared.speak("음량 테스트")
    }

    func updateSpeechRate(_ value: Float) {
        speechRate = value
        settingsManager.speechRate = value
        SpeechService.shared.speak("속도 테스트")
    }

    func toggleTutorial() {
        tutorialEnabled.toggle()
        settingsManager.tutorialEnabled = tutorialEnabled
        HapticService.shared.selection()
        let status = tutorialEnabled ? "켜짐" : "꺼짐"
        SpeechService.shared.speak("튜토리얼 \(status)")
    }

    func toggleHaptic() {
        hapticEnabled.toggle()
        settingsManager.hapticEnabled = hapticEnabled
        if hapticEnabled {
            HapticService.shared.success()
        }
        let status = hapticEnabled ? "켜짐" : "꺼짐"
        SpeechService.shared.speak("햅틱 피드백 \(status)")
    }

    func setDefaultSpread(_ spread: TarotSpread) {
        defaultSpread = spread
        settingsManager.defaultSpread = spread
        HapticService.shared.selection()
        SpeechService.shared.speak("기본 스프레드: \(spread.koreanName)")
    }

    func resetTutorials() {
        settingsManager.settings.homeTutorialShown = false
        settingsManager.settings.logsTutorialShown = false
        settingsManager.settings.settingsTutorialShown = false
        HapticService.shared.success()
        SpeechService.shared.speak("튜토리얼이 초기화되었습니다")
    }

    func resetAllSettings() {
        settingsManager.resetToDefaults()

        speechVolume = settingsManager.speechVolume
        speechRate = settingsManager.speechRate
        tutorialEnabled = settingsManager.tutorialEnabled
        hapticEnabled = settingsManager.hapticEnabled
        defaultSpread = settingsManager.defaultSpread

        HapticService.shared.success()
        SpeechService.shared.speak("모든 설정이 초기화되었습니다")
    }
}
