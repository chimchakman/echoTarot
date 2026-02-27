import Foundation
import SwiftUI

enum AppGesture: Equatable, Sendable {
    case tap
    case swipeLeft
    case swipeRight
    case swipeUp
    case swipeDown
    case pinchIn
    case pinchOut
    case longPress

    var description: String {
        switch self {
        case .tap: return "Tap"
        case .swipeLeft: return "Swipe left"
        case .swipeRight: return "Swipe right"
        case .swipeUp: return "Swipe up"
        case .swipeDown: return "Swipe down"
        case .pinchIn: return "Pinch in"
        case .pinchOut: return "Pinch out"
        case .longPress: return "Long press"
        }
    }

    var accessibilityAction: String {
        switch self {
        case .tap: return "Activate"
        case .swipeLeft: return "Previous"
        case .swipeRight: return "Next"
        case .swipeUp: return "Confirm"
        case .swipeDown: return "Cancel"
        case .pinchIn: return "Settings"
        case .pinchOut: return "Help"
        case .longPress: return "More options"
        }
    }
}

@MainActor
final class GestureHandler: ObservableObject {
    static let shared = GestureHandler()

    @Published var lastGesture: AppGesture?

    private init() {}

    func handleGesture(_ gesture: AppGesture) {
        lastGesture = gesture
        HapticService.shared.swipe()
    }

    func reset() {
        lastGesture = nil
    }
}
