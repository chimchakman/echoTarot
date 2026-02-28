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
├── Package.swift                  # Swift 패키지 설정
├── Info.plist                     # 앱 권한 및 메타데이터
├── Model/                         # 데이터 모델
│   ├── TarotCard.swift           # 카드 정보
│   ├── TarotReading.swift        # 리딩 기록 (SwiftData)
│   ├── TarotSpread.swift         # 스프레드 타입
│   ├── AppSettings.swift         # 앱 설정
│   └── CardKeywordCustomization.swift  # 카드 키워드 커스터마이징
├── ViewModel/                     # 뷰모델
│   ├── HomeViewModel.swift       # 홈 화면 상태 관리
│   ├── LogsViewModel.swift       # 기록 화면 상태 관리
│   └── SettingsViewModel.swift   # 설정 화면 상태 관리
├── View/
│   ├── Components/               # 재사용 컴포넌트
│   │   ├── AccessibleCard.swift          # 접근성 카드 컴포넌트
│   │   ├── CardImageDescriptionButton.swift  # 카드 이미지 설명 버튼
│   │   ├── FullScreenButton.swift        # 전체화면 버튼
│   │   ├── GestureOverlay.swift          # 제스처 오버레이
│   │   ├── KeywordChipView.swift         # 키워드 칩 뷰
│   │   ├── PageIndicator.swift           # 페이지 인디케이터
│   │   ├── TutorialOverlay.swift         # 튜토리얼 오버레이
│   │   └── VoiceRecordButton.swift       # 음성 녹음 버튼
│   ├── Navigation/               # 네비게이션 시스템
│   │   ├── AppNavigation.swift           # 앱 네비게이션 구조
│   │   └── NavigationState.swift         # 네비게이션 상태 관리
│   └── Screens/                  # 화면별 뷰
│       ├── Home/                 # 홈 화면 (8개 상태 뷰)
│       │   ├── HomeView.swift            # 홈 메인 뷰
│       │   ├── IdleStateView.swift       # 대기 상태
│       │   ├── QuestionRecordingView.swift  # 질문 녹음
│       │   ├── CardDrawingView.swift     # 카드 뽑기
│       │   ├── CardRevealedView.swift    # 카드 공개
│       │   ├── ReadingRecordingView.swift   # 리딩 녹음
│       │   ├── HashtagInputView.swift    # 해시태그 입력
│       │   └── ReadingCompleteView.swift # 리딩 완료
│       ├── Logs/                 # 기록 화면
│       │   ├── LogsView.swift            # 기록 메인 뷰
│       │   ├── CardReadingsListView.swift   # 카드 리딩 목록
│       │   ├── FilterView.swift          # 필터 뷰
│       │   ├── ReadingDetailView.swift   # 리딩 상세 뷰
│       │   ├── ReadingRowView.swift      # 리딩 행 뷰
│       │   └── TarotCardDictionaryView.swift  # 타로 카드 사전
│       └── Settings/             # 설정 화면
│           ├── SettingsView.swift        # 설정 메인 뷰
│           ├── HashtagSettingsView.swift # 해시태그 설정
│           ├── SpreadSettingsView.swift  # 스프레드 설정
│           ├── TutorialSettingsView.swift   # 튜토리얼 설정
│           └── VolumeSettingView.swift   # 볼륨 설정
├── Services/                      # 서비스 레이어
│   ├── Accessibility/            # TTS, 햅틱, 음성입력
│   │   ├── SpeechService.swift           # TTS 서비스
│   │   ├── HapticService.swift           # 햅틱 피드백
│   │   └── VoiceInputService.swift       # 음성 입력 서비스
│   ├── Gestures/                 # 제스처 시스템
│   │   ├── GestureHandler.swift          # 제스처 핸들러
│   │   └── FullScreenGestureModifier.swift  # 전체화면 제스처 수정자
│   ├── PersistenceManager.swift  # SwiftData 저장
│   ├── SettingsManager.swift     # UserDefaults 설정
│   ├── AudioFileManager.swift    # 녹음 관리
│   ├── TutorialManager.swift     # 튜토리얼 관리
│   ├── HashtagManager.swift      # 해시태그 관리
│   └── TarotImageDescriptionService.swift  # 카드 이미지 설명 서비스
└── Resources/                     # 리소스
    ├── TarotCardData.swift       # 78장 카드 데이터
    ├── TarotImageDescriptionData.swift  # 카드 이미지 설명 데이터
    └── TutorialScripts.swift     # 튜토리얼 스크립트
```
