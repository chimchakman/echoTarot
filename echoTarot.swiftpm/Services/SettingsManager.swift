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

    // MARK: - Card Keyword Customization

    func customization(for cardId: String) -> CardKeywordCustomization {
        settings.cardKeywordCustomizations[cardId] ?? .empty
    }

    func setCustomization(_ customization: CardKeywordCustomization, for cardId: String) {
        if customization.isEmpty {
            settings.cardKeywordCustomizations.removeValue(forKey: cardId)
        } else {
            settings.cardKeywordCustomizations[cardId] = customization
        }
    }

    func addUprightKeyword(_ keyword: String, for cardId: String) {
        var c = customization(for: cardId)
        let trimmed = keyword.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty, !c.addedUpright.contains(trimmed) else { return }
        c.addedUpright.append(trimmed)
        setCustomization(c, for: cardId)
    }

    func removeUprightKeyword(_ keyword: String, for cardId: String, baseKeywords: [String]) {
        var c = customization(for: cardId)
        if c.addedUpright.contains(keyword) {
            c.addedUpright.removeAll { $0 == keyword }
        } else if baseKeywords.contains(keyword), !c.removedUpright.contains(keyword) {
            c.removedUpright.append(keyword)
        }
        setCustomization(c, for: cardId)
    }

    func addReversedKeyword(_ keyword: String, for cardId: String) {
        var c = customization(for: cardId)
        let trimmed = keyword.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty, !c.addedReversed.contains(trimmed) else { return }
        c.addedReversed.append(trimmed)
        setCustomization(c, for: cardId)
    }

    func removeReversedKeyword(_ keyword: String, for cardId: String, baseKeywords: [String]) {
        var c = customization(for: cardId)
        if c.addedReversed.contains(keyword) {
            c.addedReversed.removeAll { $0 == keyword }
        } else if baseKeywords.contains(keyword), !c.removedReversed.contains(keyword) {
            c.removedReversed.append(keyword)
        }
        setCustomization(c, for: cardId)
    }

    func effectiveMeaning(for card: TarotCard, isReversed: Bool) -> String {
        let c = customization(for: card.id)
        let base = (isReversed ? card.reversedMeaning : card.uprightMeaning)
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        let removed = isReversed ? c.removedReversed : c.removedUpright
        let added   = isReversed ? c.addedReversed   : c.addedUpright
        return (base.filter { !removed.contains($0) } + added).joined(separator: ", ")
    }

    func resetKeywords(for cardId: String) {
        settings.cardKeywordCustomizations.removeValue(forKey: cardId)
    }
}
