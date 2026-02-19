import SwiftUI

struct GestureOverlay<Content: View>: View {
    let content: Content
    let onTap: (() -> Void)?
    let onSwipeLeft: (() -> Void)?
    let onSwipeRight: (() -> Void)?
    let onSwipeUp: (() -> Void)?
    let onSwipeDown: (() -> Void)?
    let onPinchIn: (() -> Void)?
    let onPinchOut: (() -> Void)?

    init(
        @ViewBuilder content: () -> Content,
        onTap: (() -> Void)? = nil,
        onSwipeLeft: (() -> Void)? = nil,
        onSwipeRight: (() -> Void)? = nil,
        onSwipeUp: (() -> Void)? = nil,
        onSwipeDown: (() -> Void)? = nil,
        onPinchIn: (() -> Void)? = nil,
        onPinchOut: (() -> Void)? = nil
    ) {
        self.content = content()
        self.onTap = onTap
        self.onSwipeLeft = onSwipeLeft
        self.onSwipeRight = onSwipeRight
        self.onSwipeUp = onSwipeUp
        self.onSwipeDown = onSwipeDown
        self.onPinchIn = onPinchIn
        self.onPinchOut = onPinchOut
    }

    var body: some View {
        content
            .fullScreenGestures(
                onTap: onTap,
                onSwipeLeft: onSwipeLeft,
                onSwipeRight: onSwipeRight,
                onSwipeUp: onSwipeUp,
                onSwipeDown: onSwipeDown,
                onPinchIn: onPinchIn,
                onPinchOut: onPinchOut
            )
    }
}
