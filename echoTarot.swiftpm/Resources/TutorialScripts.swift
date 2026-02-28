import Foundation

struct TutorialScripts {

    static let welcomeScripts: [String] = [
        "Welcome to Echo Tarot.",
        "This app is a tarot diary designed for visually impaired users.",
        "You can ask questions, draw tarot cards, and record your readings.",
        "The Voice guide will help you interpret your cards.",
        "Swipe left or right to navigate between screens.",
        "You're ready to begin. Tap the screen to start your first reading."
    ]

    static let homeScripts: [String] = [
        "Home screen.",
        "Tap the screen to start a tarot reading.",
        "You can record your question, draw cards, and then record your reading.",
        "Tap the spread button to choose between One Card and Three Card spreads.",
        "Swipe right to go to the Logs screen, and Swipe left to go to the Settings screen."
    ]

    static let logsScripts: [String] = [
        "Logs screen.",
        "Here you can review your previously saved tarot readings.",
        "Tap any entry to see its details.",
        "Use the filter button in the top right to sort or filter your readings.",
        "Swipe left to go to the Home screen."
    ]

    static let settingsScripts: [String] = [
        "Settings screen.",
        "You can adjust the volume and speaking speed.",
        "You can disable or reset tutorials.",
        "Choose your default spread and configure haptic feedback.",
        "Swipe right to return to the Home screen."
    ]

    static func scripts(for screen: String) -> [String] {
        switch screen {
        case "welcome":
            return welcomeScripts
        case "home":
            return homeScripts
        case "logs":
            return logsScripts
        case "settings":
            return settingsScripts
        default:
            return []
        }
    }
}
