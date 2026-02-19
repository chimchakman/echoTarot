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
        case .tap: return "탭"
        case .swipeLeft: return "왼쪽으로 스와이프"
        case .swipeRight: return "오른쪽으로 스와이프"
        case .swipeUp: return "위로 스와이프"
        case .swipeDown: return "아래로 스와이프"
        case .pinchIn: return "핀치 인"
        case .pinchOut: return "핀치 아웃"
        case .longPress: return "길게 누르기"
        }
    }

    var accessibilityAction: String {
        switch self {
        case .tap: return "활성화"
        case .swipeLeft: return "이전"
        case .swipeRight: return "다음"
        case .swipeUp: return "확인"
        case .swipeDown: return "취소"
        case .pinchIn: return "설정"
        case .pinchOut: return "도움말"
        case .longPress: return "추가 옵션"
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
