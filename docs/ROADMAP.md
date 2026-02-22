# 완등 MVP 로드맵

핵심 플로우: **촬영 → 저장 → 캘린더 기록 확인 → 지도에서 암장 탐색**을 실제 동작하게 만드는 것이 목표.

---

## Phase 1: 로컬 데이터 기반 구축

> 더미 데이터를 걷어내고, 촬영한 영상이 실제로 기록되고 조회되는 구조를 만든다.

### 1-1. 로컬 DB 도입 (sqflite 또는 drift)

- [ ] 데이터 모델 정의
  - `ClimbRecord`: id, gymName, difficulty, isCompleted, tags, videoPath, thumbnailPath, recordedAt, duration
  - `Gym`: id, name, address, lat, lng, rating, facilities
- [ ] DB 헬퍼 클래스 작성 (CRUD 메서드)
- [ ] 앱 초기화 시 DB 생성

### 1-2. 촬영 → 저장 플로우 연결

- [ ] RecordScreen의 `_saveVideo()` 에서 DB에 `ClimbRecord` INSERT
- [ ] 영상 저장 경로를 체계적으로 관리 (날짜별 디렉토리)
- [ ] 영상 썸네일 자동 생성 (video_thumbnail 패키지 또는 첫 프레임 캡처)

### 1-3. 캘린더 실제 데이터 연동

- [ ] CalendarScreen에서 DB의 `ClimbRecord` 조회
- [ ] 더미 `_climbingRecords` 맵 제거 → DB 쿼리로 대체
- [ ] 월간 이동 기능 추가 (현재 일 단위만 가능)
- [ ] 기록 탭 시 실제 저장된 영상 재생

### 1-4. 비디오 플레이어 실제 동작

- [ ] VideoPlayerScreen에서 `video_player` 패키지로 실제 영상 재생
- [ ] 로컬 파일 경로를 받아서 재생 (현재 더미 UI만 존재)

**Phase 1 완료 기준**: 촬영 → 저장 → 캘린더에서 날짜 선택 → 실제 영상 재생까지 끊김 없이 동작

---

## Phase 2: 상태 관리 도입 & 네비게이션 정리

> StatefulWidget 기반 코드를 정리하고, 미연결 화면을 연결한다.

### 2-1. 상태 관리 도입 (Riverpod 권장)

- [ ] `flutter_riverpod` 의존성 추가
- [ ] ClimbRecord 관련 Provider 작성
  - `climbRecordsProvider`: 전체 기록 조회
  - `recordsByDateProvider(date)`: 날짜별 기록
  - `recordsByGymProvider(gymName)`: 암장별 기록
- [ ] CalendarScreen, RecordScreen을 ConsumerWidget으로 전환
- [ ] 기록 추가/삭제 시 자동 UI 갱신

### 2-2. 네비게이션 구조 확장

- [ ] `main.dart`의 IndexedStack에 HomeScreen 추가 (탭 0으로 이동)
- [ ] 바텀 네비게이션 탭 구성 변경: 홈 / 지도 / (촬영 FAB) / 캘린더 / 프로필
- [ ] WandengBottomNavBar 위젯 업데이트

### 2-3. HomeScreen 실데이터 연동

- [ ] MonthlySummaryCard: DB에서 이번 달 기록 집계 (총 등반 수, 완등률, 최고 난이도)
- [ ] RecentClimbRecordSection: DB에서 최근 3개 기록 조회
- [ ] FavoriteGymSection: 가장 많이 방문한 암장 상위 N개

**Phase 2 완료 기준**: 홈→지도→촬영→캘린더→프로필 전체 탭이 연결되고, 데이터가 Provider를 통해 공유됨

---

## Phase 3: 지도 기능 완성

> 네이버 지도를 실제로 활용할 수 있게 만든다.

### 3-1. GPS 위치 연동

- [ ] `geolocator` 패키지 추가
- [ ] 위치 권한 요청 (Android/iOS)
- [ ] 현재 위치 버튼 → 실제 GPS 좌표로 카메라 이동
- [ ] RecordScreen의 `_detectNearbyGym()` → 실제 GPS 기반 근처 암장 감지

### 3-2. 암장 데이터 관리

- [ ] 로컬 DB에 기본 암장 데이터 시드 (서울 주요 암장 20~30개)
- [ ] 암장 검색 기능 구현 (이름/지역 텍스트 검색 → DB 쿼리)
- [ ] 필터 칩 적용 로직 (영업중, 주차가능 등 → facilities 필드 기반 필터)

### 3-3. 지도 ↔ 기록 연결

- [ ] 암장 카드 탭 → 해당 암장의 내 기록 목록 표시
- [ ] 암장별 방문 횟수, 최고 난이도 표시

**Phase 3 완료 기준**: 내 위치 기반으로 암장을 탐색하고, 선택한 암장의 내 기록을 볼 수 있음

---

## Phase 4: 기록 관리 고도화

> 기록을 수정/삭제하고, 통계를 확인할 수 있게 한다.

### 4-1. 기록 편집

- [ ] 기록 상세 화면에서 난이도, 완등 여부, 태그 수정 기능
- [ ] 기록 삭제 (확인 다이얼로그 + 영상 파일 삭제)
- [ ] 캘린더에서 직접 기록 추가 (영상 없이 수기 기록)

### 4-2. 프로필 통계 실데이터

- [ ] ProfileScreen 성장 기록 탭: DB 기반 월별 완등 수 차트
- [ ] 난이도별 완등률: DB 집계 → 프로그레스 바
- [ ] Climb Passport: 실제 방문 암장 기반 스탬프
- [ ] 최고 완등 난이도: DB에서 최고 난이도 조회

### 4-3. 프로필 편집

- [ ] 닉네임, 칭호 수정
- [ ] 신체 스펙(신장, 윙스팬) 수정 → 로컬 저장 (SharedPreferences 또는 DB)
- [ ] 프로필 사진 설정 (image_picker)

**Phase 4 완료 기준**: 기록을 자유롭게 관리하고, 프로필에서 실제 통계를 확인할 수 있음

---

## Phase 별 우선순위 요약

```
Phase 1 (로컬 DB + 핵심 플로우)     ← 가장 먼저. 앱의 핵심 가치 구현
Phase 2 (상태 관리 + 네비게이션)     ← 코드 구조 정리. Phase 3~4의 기반
Phase 3 (지도 실사용)               ← GPS 연동으로 암장 탐색 실용화
Phase 4 (기록 고도화 + 프로필)       ← 사용자 경험 완성
```

## MVP 범위 밖 (추후 검토)

아래 기능들은 MVP 이후 백엔드(FastAPI) 구축과 함께 진행:

- 사용자 인증 (회원가입/로그인)
- 영상 업로드 & 공유 (서버 저장소)
- 커뮤니티/크루 기능 (CrewScreen 활성화)
- AI 코치 분석 (CoachScreen 활성화)
- 실시간 암장 혼잡도
- AR 루트 파인더
- 푸시 알림
