import Foundation
import SwiftUI
import UIKit

enum AppScreen: String, CaseIterable, Sendable {
    case logs = "Logs"
    case home = "Home"
    case settings = "Settings"

    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .logs: return "book.fill"
        case .settings: return "gearshape.fill"
        }
    }

    var accessibilityLabel: String {
        switch self {
        case .home: return "Home screen, draw tarot cards"
        case .logs: return "Logs screen, view previous readings"
        case .settings: return "Settings screen"
        }
    }
}

@MainActor
final class NavigationState: ObservableObject {
    static let shared = NavigationState()

    @Published var currentScreen: AppScreen = .home
    @Published var showSettings = false
    @Published var showTutorial = false
    @Published var isReadingActive: Bool = false

    private init() {}

    func navigate(to screen: AppScreen) {
        guard screen != currentScreen else { return }

        HapticService.shared.navigate()
        SpeechService.shared.stop()
        if !UIAccessibility.isVoiceOverRunning {
            SpeechService.shared.speak("\(screen.rawValue) screen")
        } else {
            // Post custom announcement instead of .screenChanged to control exactly what is spoken
            SpeechService.shared.announceAfterDelay(
                screenAnnouncement(for: screen),
                delay: SpeechService.mediumDelay
            )
        }

        withAnimation(.easeInOut(duration: 0.3)) {
            currentScreen = screen
        }
    }

    /// Returns the VoiceOver announcement for a given screen
    /// - Parameter screen: The screen to announce
    /// - Returns: Announcement string
    func screenAnnouncement(for screen: AppScreen) -> String {
        switch screen {
        case .home:
            return "Home."
        case .logs:
            let count = (try? PersistenceManager.shared.fetchAllReadings().count) ?? 0
            return "Logs. \(count) readings."
        case .settings:
            return "Settings."
        }
    }

    func navigateLeft() {
        let screens = AppScreen.allCases
        guard let currentIndex = screens.firstIndex(of: currentScreen) else { return }

        guard currentIndex > 0 else { return }
        navigate(to: screens[currentIndex - 1])
    }

    func navigateRight() {
        let screens = AppScreen.allCases
        guard let currentIndex = screens.firstIndex(of: currentScreen) else { return }

        guard currentIndex < screens.count - 1 else { return }
        navigate(to: screens[currentIndex + 1])
    }

    func openSettings() {
        HapticService.shared.pinch()
        showSettings = true
        if !UIAccessibility.isVoiceOverRunning {
            SpeechService.shared.speak("Opening Settings")
        }
    }

    func openTutorial() {
        HapticService.shared.pinch()
        showTutorial = true
        if !UIAccessibility.isVoiceOverRunning {
            SpeechService.shared.speak("Help")
        }
    }
}
