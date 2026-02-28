import Foundation
import AVFoundation
import UIKit

@MainActor
final class SpeechService: NSObject, ObservableObject {
    static let shared = SpeechService()

    @Published var isSpeaking = false

    private let synthesizer = AVSpeechSynthesizer()
    private var completionHandler: (() -> Void)?

    var isVoiceOverRunning: Bool {
        UIAccessibility.isVoiceOverRunning
    }

    // MARK: - Delay Constants for VoiceOver Coordination
    /// Short delay for minor transitions (focus setting after view render)
    static let shortDelay: TimeInterval = 0.3
    /// Medium delay for screen transitions (allows VoiceOver to settle)
    static let mediumDelay: TimeInterval = 0.5
    /// Long delay for cold start or complex transitions
    static let longDelay: TimeInterval = 1.0
    /// Extra long delay for focus THEN announcement sequencing
    static let focusThenAnnounceDelay: TimeInterval = 0.8

    override private init() {
        super.init()
        synthesizer.delegate = self
    }

    func speak(_ text: String, completion: (() -> Void)? = nil) {
        if isVoiceOverRunning {
            speakViaVoiceOver(text, completion: completion)
        } else {
            speakViaSynthesizer(text, completion: completion)
        }
    }

    private func speakViaVoiceOver(_ text: String, completion: (() -> Void)? = nil) {
        UIAccessibility.post(notification: .announcement, argument: text)
        let estimatedDuration = Double(text.count) * 0.05 + 0.5
        DispatchQueue.main.asyncAfter(deadline: .now() + estimatedDuration) {
            completion?()
        }
    }

    /// Announces text via VoiceOver with a delay to avoid overlapping with automatic focus announcements.
    /// Use this for screen transition announcements where VoiceOver may auto-read focused elements.
    /// - Parameters:
    ///   - text: The announcement text
    ///   - delay: Time to wait before posting announcement (default: mediumDelay)
    ///   - completion: Optional callback after estimated speech duration
    func announceAfterDelay(_ text: String, delay: TimeInterval = SpeechService.mediumDelay, completion: (() -> Void)? = nil) {
        guard UIAccessibility.isVoiceOverRunning else {
            speak(text, completion: completion)
            return
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            UIAccessibility.post(notification: .announcement, argument: text)
            let estimatedDuration = Double(text.count) * 0.05 + 0.5
            DispatchQueue.main.asyncAfter(deadline: .now() + estimatedDuration) {
                completion?()
            }
        }
    }

    private func speakViaSynthesizer(_ text: String, completion: (() -> Void)? = nil) {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        completionHandler = nil
        isSpeaking = false

        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = SettingsManager.shared.speechRate
        utterance.volume = SettingsManager.shared.speechVolume
        utterance.pitchMultiplier = 1.0

        completionHandler = completion
        isSpeaking = true
        synthesizer.speak(utterance)
    }

    func speakWithPause(_ texts: [String], pauseDuration: TimeInterval = 0.5) {
        var index = 0

        func speakNext() {
            guard index < texts.count else { return }
            let text = texts[index]
            index += 1

            speak(text) {
                if index < texts.count {
                    DispatchQueue.main.asyncAfter(deadline: .now() + pauseDuration) {
                        speakNext()
                    }
                }
            }
        }

        speakNext()
    }

    func speakMinimal(_ text: String) {
        if !isVoiceOverRunning {
            speak(text)
        }
    }

    /// Always speaks via AVSpeechSynthesizer, regardless of VoiceOver state.
    /// Use this when the app controls audio exclusively (e.g. tutorial overlay).
    func speakAlways(_ text: String, completion: (() -> Void)? = nil) {
        speakViaSynthesizer(text, completion: completion)
    }

    func stop() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        isSpeaking = false
        completionHandler = nil
    }

    func pause() {
        synthesizer.pauseSpeaking(at: .word)
    }

    func resume() {
        synthesizer.continueSpeaking()
    }
}

extension SpeechService: AVSpeechSynthesizerDelegate {
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        Task { @MainActor in
            self.isSpeaking = false
            self.completionHandler?()
            self.completionHandler = nil
        }
    }

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        Task { @MainActor in
            self.isSpeaking = false
        }
    }
}
