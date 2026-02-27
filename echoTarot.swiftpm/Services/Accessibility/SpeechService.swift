import Foundation
import AVFoundation

@MainActor
final class SpeechService: NSObject, ObservableObject {
    static let shared = SpeechService()

    @Published var isSpeaking = false

    private let synthesizer = AVSpeechSynthesizer()
    private var completionHandler: (() -> Void)?

    override private init() {
        super.init()
        synthesizer.delegate = self
    }

    func speak(_ text: String, completion: (() -> Void)? = nil) {
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
