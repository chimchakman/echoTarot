import Foundation
import AVFoundation
#if os(iOS)
import UIKit
#endif

@MainActor
final class AudioFileManager: NSObject, ObservableObject {
    static let shared = AudioFileManager()

    @Published var isRecording = false
    @Published var isPlaying = false
    @Published var currentlyPlayingURL: URL?
    @Published var recordingDuration: TimeInterval = 0

    private var audioRecorder: AVAudioRecorder?
    private var audioPlayer: AVAudioPlayer?
    private var recordingTimer: Timer?

    private let fileManager = FileManager.default

    private var recordingsDirectory: URL {
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let recordingsPath = documentsPath.appendingPathComponent("Recordings", isDirectory: true)

        if !fileManager.fileExists(atPath: recordingsPath.path) {
            try? fileManager.createDirectory(at: recordingsPath, withIntermediateDirectories: true)
        }

        return recordingsPath
    }

    override private init() {
        super.init()
        setupAudioSession()
    }

    private func setupAudioSession() {
        #if os(iOS)
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetooth])
        } catch {
            print("Failed to setup audio session: \(error)")
        }
        #endif
    }

    func generateFilePath(for type: RecordingType) -> URL {
        let filename = "\(type.rawValue)_\(UUID().uuidString).m4a"
        return recordingsDirectory.appendingPathComponent(filename)
    }

    func startRecording(to url: URL) throws {
        #if os(iOS)
        if #available(iOS 17.0, *) {
            guard AVAudioApplication.shared.recordPermission == .granted else {
                throw RecordingError.permissionDenied
            }
        } else {
            guard AVAudioSession.sharedInstance().recordPermission == .granted else {
                throw RecordingError.permissionDenied
            }
        }

        // Activate audio session now that permission is granted
        try AVAudioSession.sharedInstance().setActive(true, options: [])
        #endif

        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        audioRecorder = try AVAudioRecorder(url: url, settings: settings)
        audioRecorder?.prepareToRecord()
        audioRecorder?.record()
        isRecording = true
        recordingDuration = 0

        recordingTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.recordingDuration = self?.audioRecorder?.currentTime ?? 0
            }
        }
    }

    func stopRecording() -> URL? {
        recordingTimer?.invalidate()
        recordingTimer = nil

        let url = audioRecorder?.url
        audioRecorder?.stop()
        audioRecorder = nil
        isRecording = false

        #if os(iOS)
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        #endif

        return url
    }

    func playAudio(from url: URL) throws {
        #if os(iOS)
        try AVAudioSession.sharedInstance().setActive(true, options: [])
        #endif
        audioPlayer = try AVAudioPlayer(contentsOf: url)
        audioPlayer?.delegate = self
        audioPlayer?.play()
        isPlaying = true
        currentlyPlayingURL = url
    }

    func stopPlaying() {
        audioPlayer?.stop()
        audioPlayer = nil
        isPlaying = false
        currentlyPlayingURL = nil
        #if os(iOS)
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        #endif
    }

    func deleteRecording(at path: String) {
        let url = URL(fileURLWithPath: path)
        try? fileManager.removeItem(at: url)
    }

    func getAudioDuration(for url: URL) -> TimeInterval? {
        guard let player = try? AVAudioPlayer(contentsOf: url) else { return nil }
        return player.duration
    }
}

extension AudioFileManager: AVAudioPlayerDelegate {
    nonisolated func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        Task { @MainActor in
            self.isPlaying = false
            self.currentlyPlayingURL = nil
        }
    }
}

enum RecordingType: String {
    case question = "question"
    case reading = "reading"
}

enum RecordingError: LocalizedError {
    case permissionDenied

    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Microphone access is required to record. Please enable it in Settings."
        }
    }
}
