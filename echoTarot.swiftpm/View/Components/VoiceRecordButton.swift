import SwiftUI
import AVFoundation

struct VoiceRecordButton: View {
    @ObservedObject var audioManager = AudioFileManager.shared

    let recordingType: RecordingType
    let onRecordingComplete: (URL) -> Void

    @State private var recordingURL: URL?
    @State private var isRecording = false

    var body: some View {
        VStack(spacing: 24) {
            // Recording indicator
            Circle()
                .fill(isRecording ? Color.red : Color.white.opacity(0.3))
                .frame(width: 120, height: 120)
                .overlay(
                    Image(systemName: isRecording ? "stop.fill" : "mic.fill")
                        .font(.system(size: 48))
                        .foregroundColor(isRecording ? .white : .white.opacity(0.8))
                )
                .scaleEffect(isRecording ? 1.1 : 1.0)
                .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: isRecording)

            // Status text
            Text(isRecording ? "Recording..." : "Tap to start recording")
                .font(.title2)
                .foregroundColor(.white)

            // Duration
            if isRecording {
                Text(formatDuration(audioManager.recordingDuration))
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.8))
                    .monospacedDigit()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: 300)
        .contentShape(Rectangle())
        .onTapGesture {
            toggleRecording()
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(isRecording ? "Recording, \(formatDuration(audioManager.recordingDuration))" : "Record button")
        .accessibilityHint(isRecording ? "Tap to stop recording" : "Tap to start recording")
        .accessibilityAddTraits(.isButton)
        .accessibilityAction(.default) {
            toggleRecording()
        }
    }

    private func toggleRecording() {
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }

    private func startRecording() {
        #if os(iOS)
        if #available(iOS 17.0, *) {
            let currentPermission = AVAudioApplication.shared.recordPermission
            switch currentPermission {
            case .granted:
                beginRecording()
            case .undetermined:
                Task {
                    let granted = await AVAudioApplication.requestRecordPermission()
                    await MainActor.run {
                        if granted {
                            self.beginRecording()
                        } else {
                            HapticService.shared.error()
                            SpeechService.shared.speak("Microphone access denied. Please enable microphone access in Settings.")
                        }
                    }
                }
            case .denied:
                HapticService.shared.error()
                SpeechService.shared.speak("Microphone access denied. Please enable microphone access in Settings.")
            @unknown default:
                HapticService.shared.error()
                SpeechService.shared.speak("Unable to access microphone.")
            }
        } else {
            let session = AVAudioSession.sharedInstance()
            let currentPermission = session.recordPermission
            switch currentPermission {
            case .granted:
                beginRecording()
            case .undetermined:
                session.requestRecordPermission { granted in
                    DispatchQueue.main.async {
                        if granted {
                            self.beginRecording()
                        } else {
                            HapticService.shared.error()
                            SpeechService.shared.speak("Microphone access denied. Please enable microphone access in Settings.")
                        }
                    }
                }
            case .denied:
                HapticService.shared.error()
                SpeechService.shared.speak("Microphone access denied. Please enable microphone access in Settings.")
            @unknown default:
                HapticService.shared.error()
                SpeechService.shared.speak("Unable to access microphone.")
            }
        }
        #endif
    }

    private func beginRecording() {
        #if os(iOS)
        HapticService.shared.recordingStarted()
        SpeechService.shared.speak("Starting recording")
        #endif

        let url = audioManager.generateFilePath(for: recordingType)
        recordingURL = url

        do {
            try audioManager.startRecording(to: url)
            isRecording = true
        } catch {
            #if os(iOS)
            HapticService.shared.error()
            SpeechService.shared.speak("Unable to start recording")
            #endif
        }
    }

    private func stopRecording() {
        #if os(iOS)
        HapticService.shared.recordingStopped()
        #endif

        if let url = audioManager.stopRecording() {
            #if os(iOS)
            SpeechService.shared.speak("Recording complete")
            #endif
            isRecording = false
            onRecordingComplete(url)
        }
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
