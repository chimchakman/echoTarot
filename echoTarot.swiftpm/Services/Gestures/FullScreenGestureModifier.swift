import SwiftUI

struct FullScreenGestureModifier: ViewModifier {
    let onTap: (() -> Void)?
    let onSwipeLeft: (() -> Void)?
    let onSwipeRight: (() -> Void)?
    let onSwipeUp: (() -> Void)?
    let onSwipeDown: (() -> Void)?
    let onPinchIn: (() -> Void)?
    let onPinchOut: (() -> Void)?
    let onLongPress: (() -> Void)?

    @Environment(\.accessibilityVoiceOverEnabled) private var isVoiceOverEnabled

    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0

    init(
        onTap: (() -> Void)? = nil,
        onSwipeLeft: (() -> Void)? = nil,
        onSwipeRight: (() -> Void)? = nil,
        onSwipeUp: (() -> Void)? = nil,
        onSwipeDown: (() -> Void)? = nil,
        onPinchIn: (() -> Void)? = nil,
        onPinchOut: (() -> Void)? = nil,
        onLongPress: (() -> Void)? = nil
    ) {
        self.onTap = onTap
        self.onSwipeLeft = onSwipeLeft
        self.onSwipeRight = onSwipeRight
        self.onSwipeUp = onSwipeUp
        self.onSwipeDown = onSwipeDown
        self.onPinchIn = onPinchIn
        self.onPinchOut = onPinchOut
        self.onLongPress = onLongPress
    }

    @ViewBuilder
    func body(content: Content) -> some View {
        if isVoiceOverEnabled {
            // VoiceOver active: pass through without any raw gesture recognizers.
            // Child views' .accessibilityAction(.default) will handle double-tap directly.
            // Do NOT add .accessibilityAction(.default) here when onTap is nil — a nil handler
            // at the container level intercepts and swallows child accessibility actions.
            content
                .applyIf(onTap != nil) { $0.accessibilityAction(.default) { onTap?() } }
                .applyIf(onSwipeDown != nil) { $0.accessibilityAction(.escape) { onSwipeDown?() } }
        } else {
            content
                .contentShape(Rectangle())
                .simultaneousGesture(createTapGesture())
                .simultaneousGesture(createSwipeGestures())
                .simultaneousGesture(createPinchGesture())
                .simultaneousGesture(createLongPressGesture())
        }
    }

    private func createTapGesture() -> some Gesture {
        TapGesture()
            .onEnded {
                GestureHandler.shared.handleGesture(.tap)
                HapticService.shared.tap()
                onTap?()
            }
    }

    private func createSwipeGestures() -> some Gesture {
        DragGesture(minimumDistance: 50, coordinateSpace: .local)
            .onEnded { value in
                let horizontalAmount = value.translation.width
                let verticalAmount = value.translation.height

                if abs(horizontalAmount) > abs(verticalAmount) {
                    // Horizontal swipe
                    if horizontalAmount < 0 {
                        GestureHandler.shared.handleGesture(.swipeLeft)
                        onSwipeLeft?()
                    } else {
                        GestureHandler.shared.handleGesture(.swipeRight)
                        onSwipeRight?()
                    }
                } else {
                    // Vertical swipe
                    if verticalAmount < 0 {
                        GestureHandler.shared.handleGesture(.swipeUp)
                        onSwipeUp?()
                    } else {
                        GestureHandler.shared.handleGesture(.swipeDown)
                        onSwipeDown?()
                    }
                }
            }
    }

    private func createPinchGesture() -> some Gesture {
        MagnificationGesture()
            .onChanged { value in
                scale = value
            }
            .onEnded { value in
                if value < lastScale {
                    GestureHandler.shared.handleGesture(.pinchIn)
                    HapticService.shared.pinch()
                    onPinchIn?()
                } else if value > lastScale {
                    GestureHandler.shared.handleGesture(.pinchOut)
                    HapticService.shared.pinch()
                    onPinchOut?()
                }
                lastScale = scale
                scale = 1.0
            }
    }

    private func createLongPressGesture() -> some Gesture {
        LongPressGesture(minimumDuration: 1.0)
            .onEnded { _ in
                GestureHandler.shared.handleGesture(.longPress)
                HapticService.shared.impact(.heavy)
                onLongPress?()
            }
    }
}

// MARK: - View Extension

extension View {
    @ViewBuilder
    func applyIf<T: View>(_ condition: Bool, transform: (Self) -> T) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }

    func fullScreenGestures(
        onTap: (() -> Void)? = nil,
        onSwipeLeft: (() -> Void)? = nil,
        onSwipeRight: (() -> Void)? = nil,
        onSwipeUp: (() -> Void)? = nil,
        onSwipeDown: (() -> Void)? = nil,
        onPinchIn: (() -> Void)? = nil,
        onPinchOut: (() -> Void)? = nil,
        onLongPress: (() -> Void)? = nil
    ) -> some View {
        self.modifier(FullScreenGestureModifier(
            onTap: onTap,
            onSwipeLeft: onSwipeLeft,
            onSwipeRight: onSwipeRight,
            onSwipeUp: onSwipeUp,
            onSwipeDown: onSwipeDown,
            onPinchIn: onPinchIn,
            onPinchOut: onPinchOut,
            onLongPress: onLongPress
        ))
    }
}
