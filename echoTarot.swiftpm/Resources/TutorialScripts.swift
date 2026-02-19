import Foundation

struct TutorialScripts {

    static let welcomeScripts: [String] = [
        "에코 타로에 오신 것을 환영합니다.",
        "이 앱은 시각장애인을 위한 타로 카드 앱입니다.",
        "화면 어디든 탭하여 주요 기능을 실행할 수 있습니다.",
        "왼쪽이나 오른쪽으로 스와이프하여 화면을 전환합니다.",
        "위로 스와이프하면 확인, 아래로 스와이프하면 취소입니다.",
        "핀치 인 제스처로 설정을, 핀치 아웃으로 도움말을 열 수 있습니다.",
        "이제 타로 리딩을 시작해보세요. 화면을 탭하세요."
    ]

    static let homeScripts: [String] = [
        "홈 화면입니다.",
        "화면을 탭하면 타로 리딩이 시작됩니다.",
        "먼저 질문을 녹음하고, 카드를 뽑은 후, 리딩을 녹음할 수 있습니다.",
        "스프레드 버튼을 탭하여 원 카드와 쓰리 카드 중 선택하세요.",
        "왼쪽으로 스와이프하면 기록 화면으로 이동합니다."
    ]

    static let logsScripts: [String] = [
        "기록 화면입니다.",
        "이전에 저장한 타로 리딩을 확인할 수 있습니다.",
        "각 기록을 탭하면 상세 내용을 볼 수 있습니다.",
        "오른쪽 상단의 필터 버튼으로 정렬하거나 필터링할 수 있습니다.",
        "왼쪽으로 스와이프하면 설정 화면으로 이동합니다."
    ]

    static let settingsScripts: [String] = [
        "설정 화면입니다.",
        "음량과 말하기 속도를 조절할 수 있습니다.",
        "튜토리얼을 끄거나 초기화할 수 있습니다.",
        "기본 스프레드를 선택하고, 햅틱 피드백을 설정할 수 있습니다.",
        "오른쪽으로 스와이프하면 홈 화면으로 돌아갑니다."
    ]

    static func scripts(for screen: String) -> [String] {
        switch screen {
        case "welcome":
            return welcomeScripts
        case "home":
            return homeScripts
        case "logs":
            return logsScripts
        case "settings":
            return settingsScripts
        default:
            return []
        }
    }
}
