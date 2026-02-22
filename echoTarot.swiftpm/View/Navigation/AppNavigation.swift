import SwiftUI

struct AppNavigation: View {
    @StateObject private var navigationState = NavigationState.shared
    @StateObject private var settingsManager = SettingsManager.shared

    var body: some View {
        ZStack {
            // Background
            Image("background")
                .resizable()
                .ignoresSafeArea()

            // Main content based on current screen
            Group {
                switch navigationState.currentScreen {
                case .home:
                    HomeView()
                case .logs:
                    LogsView()
                case .settings:
                    SettingsView()
                }
            }
            .transition(.opacity)

            // Page indicator at bottom
            VStack {
                Spacer()
                PageIndicator(
                    totalPages: AppScreen.allCases.count,
                    currentPage: AppScreen.allCases.firstIndex(of: navigationState.currentScreen) ?? 0
                )
            }
        }
        .fullScreenGestures(
            onSwipeLeft: { navigationState.navigateRight() },
            onSwipeRight: { navigationState.navigateLeft() },
            onPinchIn: { navigationState.openSettings() },
            onPinchOut: { navigationState.openTutorial() }
        )
        .sheet(isPresented: $navigationState.showTutorial) {
            TutorialSheet()
        }
    }

}

struct TutorialSheet: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var navigationState = NavigationState.shared

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        tutorialSection(
                            title: "제스처 안내",
                            items: [
                                ("탭", "주요 액션 실행"),
                                ("왼쪽 스와이프", "다음 화면으로 이동 (기록 → 홈 → 설정)"),
                                ("오른쪽 스와이프", "이전 화면으로 이동 (설정 → 홈 → 기록)"),
                                ("위로 스와이프", "확인/진행"),
                                ("아래로 스와이프", "취소/뒤로"),
                                ("핀치 인", "설정 열기"),
                                ("핀치 아웃", "도움말 열기")
                            ]
                        )

                        tutorialSection(
                            title: "화면 안내",
                            items: [
                                ("홈", "타로 카드를 뽑고 리딩을 녹음합니다"),
                                ("기록", "이전 리딩 기록을 확인합니다"),
                                ("설정", "앱 설정을 변경합니다")
                            ]
                        )
                    }
                    .padding()
                }
            }
            .navigationTitle("도움말")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("닫기") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func tutorialSection(title: String, items: [(String, String)]) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)

            ForEach(items, id: \.0) { item in
                HStack(alignment: .top) {
                    Text(item.0)
                        .fontWeight(.semibold)
                        .foregroundColor(.indigo)
                        .frame(width: 100, alignment: .leading)

                    Text(item.1)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
        }
    }
}
