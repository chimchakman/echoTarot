import Foundation
import UIKit

@MainActor
final class HapticService {
    static let shared = HapticService()

    private let impactLight = UIImpactFeedbackGenerator(style: .light)
    private let impactMedium = UIImpactFeedbackGenerator(style: .medium)
    private let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
    private let selectionFeedback = UISelectionFeedbackGenerator()
    private let notification = UINotificationFeedbackGenerator()

    private init() {
        prepareGenerators()
    }

    private func prepareGenerators() {
        impactLight.prepare()
        impactMedium.prepare()
        impactHeavy.prepare()
        selectionFeedback.prepare()
        notification.prepare()
    }

    private var isEnabled: Bool {
        SettingsManager.shared.hapticEnabled
    }

    // MARK: - Impact Feedback

    func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        guard isEnabled else { return }

        switch style {
        case .light:
            impactLight.impactOccurred()
        case .medium:
            impactMedium.impactOccurred()
        case .heavy:
            impactHeavy.impactOccurred()
        default:
            impactMedium.impactOccurred()
        }
    }

    // MARK: - Selection Feedback

    func selection() {
        guard isEnabled else { return }
        self.selectionFeedback.selectionChanged()
    }

    // MARK: - Notification Feedback

    func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        guard isEnabled else { return }
        notification.notificationOccurred(type)
    }

    // MARK: - Custom Patterns for App Actions

    /// Tap feedback - light impact
    func tap() {
        impact(.light)
    }

    /// Card drawn feedback - medium impact
    func cardDrawn() {
        impact(.medium)
    }

    /// Card revealed feedback - heavy impact with pattern
    func cardRevealed() {
        impact(.heavy)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.impact(.light)
        }
    }

    /// Recording started - double light tap
    func recordingStarted() {
        impact(.light)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { [weak self] in
            self?.impact(.light)
        }
    }

    /// Recording stopped - single medium
    func recordingStopped() {
        impact(.medium)
    }

    /// Success feedback
    func success() {
        notification(.success)
    }

    /// Error feedback
    func error() {
        notification(.error)
    }

    /// Warning feedback
    func warning() {
        notification(.warning)
    }

    /// Navigation feedback
    func navigate() {
        selection()
    }

    /// Swipe gesture recognized
    func swipe() {
        impact(.light)
    }

    /// Pinch gesture recognized
    func pinch() {
        impact(.medium)
    }
}
