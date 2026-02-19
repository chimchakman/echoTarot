# echoTarot

이 앱은 echoTarot이라는 이름의 시각장애인을 위한 타로 다이어리 앱이다. 언어는 swift이고, swift playground 파일로 작업 중이다.

## 코딩 스타일

- 하드코딩보다는 재사용성을 높이는 방향으로 프로그래밍한다.
- 컴포넌트 중에도 다시 쓸 수 있는 것이 있다면 가져와서 사용한다.
- 코드의 중복을 최소화하고, 공통 로직은 별도의 함수나 컴포넌트로 분리한다.

## 접근성 (Accessibility) 가이드라인

- 모든 View에 `.accessibilityLabel()` 필수
- 이미지는 `.accessibilityHidden(true)` 또는 설명 레이블 추가
- 버튼은 `.accessibilityHint()`로 동작 설명
- 제스처는 `.accessibilityAction()`으로 VoiceOver 대안 제공
- 상태 변경 시 `AccessibilityNotification.Announcement` 사용

## 제스처 규칙

- 탭: 주요 액션
- 좌/우 스와이프: 화면 전환
- 상/하 스와이프: 확인/취소
- 핀치 인/아웃: 설정/도움말

## 서비스 사용법

- TTS: `SpeechService.shared.speak("텍스트")`
- 햅틱: `HapticService.shared.impact(.medium)`
- 녹음: `AudioFileManager.shared.startRecording(to: url)`
- 설정: `SettingsManager.shared.speechVolume`
- 저장: `PersistenceManager.shared.saveReading(reading)`

## 파일 구조

```
echoTarot.swiftpm/
├── MyApp.swift                    # 앱 진입점, SwiftData 설정
├── ContentView.swift              # 루트 뷰, 튜토리얼 오버레이
├── Model/                         # 데이터 모델
│   ├── TarotCard.swift           # 카드 정보
│   ├── TarotReading.swift        # 리딩 기록 (SwiftData)
│   ├── TarotSpread.swift         # 스프레드 타입
│   └── AppSettings.swift         # 앱 설정
├── ViewModel/                     # 뷰모델
│   ├── HomeViewModel.swift       # 홈 화면 상태 관리
│   ├── LogsViewModel.swift       # 기록 화면 상태 관리
│   └── SettingsViewModel.swift   # 설정 화면 상태 관리
├── View/
│   ├── Components/               # 재사용 컴포넌트
│   ├── Navigation/               # 네비게이션 시스템
│   └── Screens/                  # 화면별 뷰
│       ├── Home/                 # 홈 화면 (6개 상태 뷰)
│       ├── Logs/                 # 기록 화면
│       └── Settings/             # 설정 화면
├── Services/                      # 서비스 레이어
│   ├── Accessibility/            # TTS, 햅틱, 음성입력
│   ├── Gestures/                 # 제스처 시스템
│   ├── PersistenceManager.swift  # SwiftData 저장
│   ├── SettingsManager.swift     # UserDefaults 설정
│   ├── AudioFileManager.swift    # 녹음 관리
│   └── TutorialManager.swift     # 튜토리얼 관리
└── Resources/                     # 리소스
    ├── TarotCardData.swift       # 78장 카드 데이터
    └── TutorialScripts.swift     # 튜토리얼 스크립트
```
