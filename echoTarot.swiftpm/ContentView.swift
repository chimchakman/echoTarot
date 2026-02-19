import SwiftUI

struct ContentView: View {
    @StateObject private var tutorialManager = TutorialManager.shared

    var body: some View {
        ZStack {
            AppNavigation()

            if tutorialManager.isShowingTutorial {
                TutorialOverlay(
                    scripts: tutorialManager.currentScripts,
                    onComplete: {
                        tutorialManager.completeTutorial()
                    }
                )
            }
        }
    }
}
