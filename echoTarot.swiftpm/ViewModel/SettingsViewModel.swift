import Foundation
import SwiftUI
import UIKit

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var speechVolume: Float
    @Published var speechRate: Float
    @Published var hapticEnabled: Bool
    @Published var defaultSpread: TarotSpread

    private let settingsManager = SettingsManager.shared

    init() {
        speechVolume = settingsManager.speechVolume
        speechRate = settingsManager.speechRate
        hapticEnabled = settingsManager.hapticEnabled
        defaultSpread = settingsManager.defaultSpread
    }

    func updateSpeechVolume(_ value: Float) {
        speechVolume = value
        settingsManager.speechVolume = value
        SpeechService.shared.speakAlways("Volume test")
    }

    func updateSpeechRate(_ value: Float) {
        speechRate = value
        settingsManager.speechRate = value
        SpeechService.shared.speakAlways("Speed test")
    }

    func toggleHaptic() {
        hapticEnabled.toggle()
        settingsManager.hapticEnabled = hapticEnabled
        if hapticEnabled {
            HapticService.shared.success()
        }
        let status = hapticEnabled ? "on" : "off"
        if !UIAccessibility.isVoiceOverRunning {
            SpeechService.shared.speak("Haptic feedback \(status)")
        }
    }

    func setDefaultSpread(_ spread: TarotSpread) {
        defaultSpread = spread
        settingsManager.defaultSpread = spread
        HapticService.shared.selection()
        if !UIAccessibility.isVoiceOverRunning {
            SpeechService.shared.speak("Default spread: \(spread.name)")
        }
    }
}
