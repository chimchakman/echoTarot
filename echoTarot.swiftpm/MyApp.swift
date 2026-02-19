import SwiftUI
import SwiftData

@main
struct MyApp: App {
    @State private var isReady = false
    
    var body: some Scene {
        WindowGroup {
            if #available(iOS 17.0, *) {
                ContentView()
                    .modelContainer(for: TarotReading.self)
                    .onAppear {
                        if !isReady {
                            isReady = true
                            TutorialManager.shared.showFirstTimeTutorial()
                        }
                    }
            } else {
                ContentView()
                    .onAppear {
                        if !isReady {
                            isReady = true
                            TutorialManager.shared.showFirstTimeTutorial()
                        }
                    }
            }
        }
    }
}
