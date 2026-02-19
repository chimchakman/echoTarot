import Foundation

@MainActor
final class SettingsManager: ObservableObject {
    static let shared = SettingsManager()

    private let defaults = UserDefaults.standard
    private let settingsKey = "echoTarot.appSettings"

    @Published var settings: AppSettings {
        didSet {
            saveSettings()
        }
    }

    private init() {
        if let data = defaults.data(forKey: settingsKey),
           let decoded = try? JSONDecoder().decode(AppSettings.self, from: data) {
            settings = decoded
        } else {
            settings = .default
        }
    }

    private func saveSettings() {
        if let encoded = try? JSONEncoder().encode(settings) {
            defaults.set(encoded, forKey: settingsKey)
        }
    }

    func resetToDefaults() {
        settings = .default
    }

    // Convenience accessors
    var speechVolume: Float {
        get { settings.speechVolume }
        set { settings.speechVolume = newValue }
    }

    var speechRate: Float {
        get { settings.speechRate }
        set { settings.speechRate = newValue }
    }

    var tutorialEnabled: Bool {
        get { settings.tutorialEnabled }
        set { settings.tutorialEnabled = newValue }
    }

    var defaultSpread: TarotSpread {
        get { settings.defaultSpread }
        set { settings.defaultSpread = newValue }
    }

    var hapticEnabled: Bool {
        get { settings.hapticEnabled }
        set { settings.hapticEnabled = newValue }
    }

    func markTutorialShown(for screen: String) {
        switch screen {
        case "home": settings.homeTutorialShown = true
        case "logs": settings.logsTutorialShown = true
        case "settings": settings.settingsTutorialShown = true
        default: break
        }
    }

    func shouldShowTutorial(for screen: String) -> Bool {
        guard settings.tutorialEnabled else { return false }
        switch screen {
        case "home": return !settings.homeTutorialShown
        case "logs": return !settings.logsTutorialShown
        case "settings": return !settings.settingsTutorialShown
        default: return false
        }
    }
}
