import SwiftUI

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
    }

    private func toggleRecording() {
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }

    private func startRecording() {
        HapticService.shared.recordingStarted()
        SpeechService.shared.speak("Starting recording")

        let url = audioManager.generateFilePath(for: recordingType)
        recordingURL = url

        do {
            try audioManager.startRecording(to: url)
            isRecording = true
        } catch {
            HapticService.shared.error()
            SpeechService.shared.speak("Unable to start recording")
        }
    }

    private func stopRecording() {
        HapticService.shared.recordingStopped()

        if let url = audioManager.stopRecording() {
            SpeechService.shared.speak("Recording complete")
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
