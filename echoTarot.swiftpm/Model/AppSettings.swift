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

    static let `default` = AppSettings(
        speechVolume: 1.0,
        speechRate: 0.5,
        tutorialEnabled: true,
        homeTutorialShown: false,
        logsTutorialShown: false,
        settingsTutorialShown: false,
        defaultSpread: .oneCard,
        hapticEnabled: true
    )
}
