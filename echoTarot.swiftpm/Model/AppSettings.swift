import Foundation

struct AppSettings: Codable, Sendable {
    var speechVolume: Float
    var speechRate: Float
    var tutorialEnabled: Bool
    var homeTutorialShown: Bool
    var logsTutorialShown: Bool
    var settingsTutorialShown: Bool
    var defaultSpread: TarotSpread
    var hapticEnabled: Bool
    var cardKeywordCustomizations: [String: CardKeywordCustomization]

    static let `default` = AppSettings(
        speechVolume: 1.0,
        speechRate: 0.5,
        tutorialEnabled: true,
        homeTutorialShown: false,
        logsTutorialShown: false,
        settingsTutorialShown: false,
        defaultSpread: .oneCard,
        hapticEnabled: true,
        cardKeywordCustomizations: [:]
    )

    enum CodingKeys: String, CodingKey {
        case speechVolume, speechRate, tutorialEnabled
        case homeTutorialShown, logsTutorialShown, settingsTutorialShown
        case defaultSpread, hapticEnabled, cardKeywordCustomizations
    }

    init(
        speechVolume: Float,
        speechRate: Float,
        tutorialEnabled: Bool,
        homeTutorialShown: Bool,
        logsTutorialShown: Bool,
        settingsTutorialShown: Bool,
        defaultSpread: TarotSpread,
        hapticEnabled: Bool,
        cardKeywordCustomizations: [String: CardKeywordCustomization] = [:]
    ) {
        self.speechVolume = speechVolume
        self.speechRate = speechRate
        self.tutorialEnabled = tutorialEnabled
        self.homeTutorialShown = homeTutorialShown
        self.logsTutorialShown = logsTutorialShown
        self.settingsTutorialShown = settingsTutorialShown
        self.defaultSpread = defaultSpread
        self.hapticEnabled = hapticEnabled
        self.cardKeywordCustomizations = cardKeywordCustomizations
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        speechVolume = try c.decode(Float.self, forKey: .speechVolume)
        speechRate = try c.decode(Float.self, forKey: .speechRate)
        tutorialEnabled = try c.decode(Bool.self, forKey: .tutorialEnabled)
        homeTutorialShown = try c.decode(Bool.self, forKey: .homeTutorialShown)
        logsTutorialShown = try c.decode(Bool.self, forKey: .logsTutorialShown)
        settingsTutorialShown = try c.decode(Bool.self, forKey: .settingsTutorialShown)
        defaultSpread = try c.decode(TarotSpread.self, forKey: .defaultSpread)
        hapticEnabled = try c.decode(Bool.self, forKey: .hapticEnabled)
        cardKeywordCustomizations = (try? c.decodeIfPresent(
            [String: CardKeywordCustomization].self,
            forKey: .cardKeywordCustomizations
        )) ?? [:]
    }
}
