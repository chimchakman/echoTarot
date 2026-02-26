import Foundation
import SwiftUI

enum AppScreen: String, CaseIterable, Sendable {
    case logs = "기록"
    case home = "홈"
    case settings = "설정"

    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .logs: return "book.fill"
        case .settings: return "gearshape.fill"
        }
    }

    var accessibilityLabel: String {
        switch self {
        case .home: return "홈 화면, 타로 카드 뽑기"
        case .logs: return "기록 화면, 이전 리딩 보기"
        case .settings: return "설정 화면"
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
        SpeechService.shared.speak("\(screen.rawValue) 화면")

        withAnimation(.easeInOut(duration: 0.3)) {
            currentScreen = screen
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
        SpeechService.shared.speak("설정 열기")
    }

    func openTutorial() {
        HapticService.shared.pinch()
        showTutorial = true
        SpeechService.shared.speak("도움말")
    }
}
