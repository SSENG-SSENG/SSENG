# SSENG – 타는 순간, 바람처럼.

> SSENG은 전동 킥보드 및 바이크 대여 플랫폼으로, 지도 기반 등록, 탑승, 반납 및 이용 내역 확인이 가능합니다.

<img src="https://github.com/user-attachments/assets/c03b04b0-08fd-4922-b6ec-1ec041e62066" width="400" alt="SSENG 화면 이미지" />

<br>

## 📋 프로젝트 개요

> SSENG은 킥보드 및 바이크를 등록·탑승·반납하고, 마이페이지에서 내 이용 내역과 탑승 상태를 확인할 수 있는 모빌리티 플랫폼입니다.

- **프로젝트 기간**: 2025.07.15(화) ~ 2025.07.22(월)
- **깃허브 링크**: [SSENG](https://github.com/SSENG-SSENG/SSENG)

<br>

## 👥 팀 구성

> 팀명: 서린님과 아이들

| 이름      | 역할       | GitHub                           |
| -------- | -------- | --------------------------------- |
| 이서린   | 킥보드 등록 화면 | [@SeorinLee](https://github.com/SeorinLee) |
| 서광용   | 마이페이지 화면 및 런치스크린 | [@MoriOS](https://github.com/Gwangyong) |
| 이태윤   | 지도 화면 | [@Lee-Tae-Yun](https://github.com/Lee-Tae-Yun) |
| 박범근   | 로그인/회원가입 및 CoreData | [@Luca Park](https://github.com/qlife1146) |

<br>

## 📂 프로젝트 구조
```
SSENG/
├── Application/
│   ├── AppDelegate.swift
│   ├── SceneDelegate.swift
│   ├── Assets.xcassets/
│   │   ├── AppIcon.appiconset/
│   │   ├── Logo.imageset/
│   │   ├── MainColor.colorset/
│   │   └── ... (기타 에셋)
│   ├── Base.lproj/
│   │   └── LaunchScreen.storyboard
│   ├── Info.plist
│   └── GreenFactory.gpx
│
├── CoreData/
│   ├── data/
│   ├── CoreDataStack.swift
│   ├── SSENG.xcdatamodeld/
│   ├── HistoryCoreData/
│   │   ├── History+CoreDataClass.swift
│   │   ├── History+CoreDataProperties.swift
│   │   └── HistoryRepository.swift
│   ├── KickboardCoreData/
│   │   ├── Kickboard+CoreDataClass.swift
│   │   ├── Kickboard+CoreDataProperties.swift
│   │   └── KickboardRepository.swift
│   └── UserCoreData/
│       ├── User+CoreDataClass.swift
│       ├── User+CoreDataProperties.swift
│       └── UserRepository.swift
│
├── Model/
│   ├── SearchModel.swift
│   └── Selected MarkerModel.swift
│
├── Network/
│   └── SearchService.swift
│
├── Protocol/
│   └── KickBoardViewControllerDelegateProtocol.swift
│
└── View/
    ├── KickBoardView/
    │   └── KickBoardViewController.swift
    ├── LoginView/
    │   ├── LoginViewController.swift
    │   └── LogoTransitionAnimator.swift
    ├── MapView/
    │   ├── MapViewController.swift
    │   └── SearchResultCell.swift
    ├── MypageView/
    │   ├── MypageViewController.swift
    │   └── Cell/
    │       ├── UserInfoCell.swift
    │       ├── KickboardRegisterCell.swift
    │       ├── KickboardHistoryCell.swift
    │       └── UIImageView+Circle.swift
    ├── SignView/
    │   ├── SignViewController.swift
    │   └── TermsViewController.swift
    └── SplashView/
        └── SplashViewController.swift
```

<br>

## 🔁 데이터 플로우
```
[[LaunchScreen]]
   ↓
[SplashViewController]
   └─▶ 자동 로그인 체크 → [LoginView] 또는 [MapView]

[LoginView]
   ├─▶ [LoginViewController]
   │     ├─▶ UserRepository → CoreDataStack → CoreData
   │     └─▶ UserDefaults (로그인 상태 저장)
   └─▶ [SignUpViewController]
         └─▶ UserRepository → CoreDataStack → CoreData

[MapView]
   ├─▶ [MapViewController]
   │     ├─▶ SearchService → Naver Local API
   │     ├─▶ KickboardRepository → CoreDataStack → CoreData
   │     ├─▶ [KickBoardViewController] (킥보드 등록)
   │     │     └─▶ Delegate 콜백
   │     └─▶ [KickBoardDetailViewController] (수정/삭제)
   └─▶ [MyPageViewController]
         ├─▶ UserRepository
         ├─▶ KickboardRepository
         └─▶ UserDefaults (로그아웃 처리)
```

<br>

## 💾 데이터 저장소 (Data Persistence)

- **Core Data**: 앱의 핵심 데이터(사용자, 킥보드, 이용 내역)는 **Core Data**를 통해 기기 내에 영구적으로 저장.  

- **Entities**: User, Kickboard, History 세 가지 주요 데이터 모델(Entity)이 정의되어 있음 

- **CoreDataStack**: Core Data의 복잡한 설정을 관리하는 싱글톤 클래스

- **UserDefaults**: 자동 로그인 상태(isAutoLogin), 현재 로그인한 사용자 ID(loggedUserID)와 같이 앱 세션 간에 필요한 간단한 데이터는 **UserDefaults**에 저장됩니다. → 사용자가 `LoginView` 또는 `MapView`에서 시작  

<br>

## 🛠️ 기술 스택

### UI Framework
- `UIKit`

### 아키텍처
- `MVC`

### 지도 API
- `NMapsGeometry` 1.0.2
- `NMapsMap` 3.22.0

### 데이터 저장
- `UserDefaults`
- `CoreData`

### 주요 라이브러리
- `Alamofire` 5.10.2
- `SnapKit` 5.7.1
- `Then` 3.0.0

<br>

## 📱 주요 기능

1. **Splash 화면 분기 처리**  
   앱 실행 시 Splash 화면을 통해 2초간 로고를 노출하고, 자동 로그인 여부에 따라 로그인 화면 또는 메인 화면으로 분기됩니다.

2. **로그인 / 회원가입 및 자동 로그인 기능**  
   사용자 정보는 CoreData를 기반으로 저장되며, 자동 로그인 여부를 체크하여 앱 시작 시 로그인 흐름을 결정합니다.

3. **킥보드 / 바이크 등록 및 지도 기반 표시**  
   사용자가 직접 킥보드를 등록할 수 있고, 등록된 킥보드는 지도 상에 위치 기반으로 시각화됩니다.

4. **대여 / 반납 기능**  
   사용자가 킥보드나 바이크에 탑승할 수 있으며, 현재 위치 기반으로 반납할 수 있습니다.

5. **마이페이지에서 등록한 킥보드 및 이용 내역 확인**  
   유저가 등록한 킥보드 목록과 이용 기록을 한 눈에 확인할 수 있도록 마이페이지에 구성하였습니다.

6. **CoreData 기반의 데이터 관리 및 저장**  
   사용자, 킥보드, 이용 내역 등 주요 데이터는 CoreData로 저장되어 앱 종료 후에도 정보를 유지합니다.

<br>

## ✍️ 커밋 컨벤션

| 이모지 | 타입       | 설명                                  |
|--------|------------|---------------------------------------|
| 📦     | Add        | 파일 및 패키지 추가                   |
| 💡     | Chore      | 간단한 기타 작업 (빌드 설정, 환경설정 등) |
| 📝     | Docs       | 문서 수정 (README, 주석 등)            |
| ✨     | Feat       | 새 기능 추가                           |
| 🚨     | Fix        | 버그 수정                              |
| 🚀     | Perf       | 성능 개선                              |
| 🔨     | Refactor   | 리팩토링 (기능 변경 없이 구조 개선)     |
| 🎨     | Style      | 코드 포맷, 세미콜론 등 스타일 변경     |
| 🗑️     | Remove     | 불필요한 코드 및 파일 삭제             |

> 예시
```
✨: 로그인 기능 구현 (#12)
```

<br>

### 🌿 브랜치 네이밍 규칙
- `feat/`, `fix/`, `style/` 등 prefix 사용  
- 예시: `feat/login`, `fix/mapview-bug`
- 병합 조건
   - ✅ PR 병합 전 **최소 1명 승인 필요**
   - ❌ `git push --force` 금지
   - 👥 모든 팀원에게 동일 규칙 적용 (Bypass 없음)


<br>

## ⛓️‍💥 와이어 프레임 
- [Figma 링크](https://www.figma.com/design/ugbya6n45zHdqH0oI5JiuR/%EC%8C%A9?node-id=0-1&p=f&t=bUX2p8ipJvFwPNo2-0)

<br>

## 📦 설치 및 실행 방법

```bash
git clone https://github.com/SSENG-SSENG/SSENG.git
open SSENG.xcodeproj
⌘R로 실행
```
