# 완등 (Wandeng) 🧗

클라이밍 커뮤니티 앱 - Flutter Dark Theme UI

## 📱 앱 소개

**완등**은 클라이머들을 위한 종합 커뮤니티 앱입니다. 베타 영상 공유, 암장 탐색, AI 코칭 등 다양한 기능을 제공합니다.

## 🎨 디자인 시스템

### 컬러 팔레트
- **배경색**: `#121212` (차콜 블랙)
- **포인트 컬러**: `#CCFF00` (네온 라임)
- **보조 컬러**: `#FF0055` (네온 핑크)
- **텍스트**: `#FFFFFF` / `#888888`

### 폰트
- Roboto (Google Fonts)

## 📂 프로젝트 구조

```
lib/
├── core/
│   └── theme/
│       ├── app_colors.dart      # 컬러 팔레트
│       ├── app_text_styles.dart # 텍스트 스타일
│       └── app_theme.dart       # 앱 테마
├── screens/
│   ├── home/
│   │   └── home_screen.dart     # 홈 피드 (틱톡 스타일)
│   ├── map/
│   │   └── map_screen.dart      # 암장 지도
│   ├── action/
│   │   └── action_modal.dart    # 액션 모달 (+)
│   ├── coach/
│   │   └── coach_screen.dart    # AI 코치
│   └── profile/
│       └── profile_screen.dart  # 마이페이지
├── widgets/
│   ├── bottom_nav_bar.dart      # 커스텀 네비게이션 바
│   ├── video_feed_item.dart     # 비디오 피드 아이템
│   └── gym_card.dart            # 암장 카드
└── main.dart
```

## 🚀 실행 방법

```bash
# 의존성 설치
flutter pub get

# 앱 실행
flutter run

# 웹으로 실행
flutter run -d chrome
```

## 📱 주요 화면

### 1. 홈 피드 (Climb Feed)
- 틱톡/릴스 스타일 세로형 비디오 피드
- 팔로잉/추천 탭
- 좋아요, 댓글, 저장, 비교 액션 버튼

### 2. 암장 지도 (Gym Map)
- 현재 위치 기반 암장 탐색
- 실시간 혼잡도 표시 (쾌적 🟢 / 보통 🟡 / 혼잡 🔴)
- 필터 기능 (영업중, 주차가능, 샤워실, 지구력벽)

### 3. 액션 버튼 (+)
- 영상 업로드
- 촬영하기 (타이머, AI 분석 옵션)
- AR 루트 파인더 (난이도별 홀드 하이라이트)

### 4. AI 코치
- 등반 스타일 분석 (레이더 차트)
- 코칭 포인트 요약
- 영상별 상세 분석 (타임라인 + 코칭 팝업)

### 5. 마이페이지
- Climb Passport (방문 암장 스탬프)
- 최고 완등 난이도 뱃지
- 내 영상 / 저장한 베타 / 성장 기록

## 📦 사용된 패키지

- `google_fonts` - 폰트
- `cached_network_image` - 이미지 캐싱
- `flutter_svg` - SVG 아이콘
- `smooth_page_indicator` - 페이지 인디케이터
- `fl_chart` - 차트 (레이더, 바 차트)

## 🔧 TODO

- [ ] 실제 동영상 재생 기능 (video_player)
- [ ] 카메라 연동 (camera)
- [ ] AR 기능 (ar_flutter_plugin)
- [ ] Google Maps 연동 (google_maps_flutter)
- [ ] 백엔드 API 연동 (FastAPI)
- [ ] 상태 관리 (Riverpod / BLoC)
- [ ] 인증 기능

## 📄 라이선스

MIT License
