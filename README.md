# 📋 Dev Backlog

| 작업 항목 | 완료 기준 | 상태 | 비고 |
|-----------|-----------|------|------|
| Challenge Response 작성 | 작성 완료 | ✅ Complete | |
| Challenge1 코드 리뷰하면서 재확인 | 작성한 코드 이해 및 복습 | ✅ Complete | |
| Dev Backlog 작성하기 | 작성 완료 | ✅ Complete | |
| Challenge1 코드 오류 수정 | Multipeer Connectivity로 카드 교환 시 정보 전달 딜레이 현상 수정 | ✅ Complete | |
| UserDefaults를 SwiftData로 교체 | 기존에 쓰던 UserDefaults를 SwiftData로 교체 | ✅ Complete | |
| Hi-fi 완성하기 | Hi-fi 파일 만들기 + 디자인 완료 | ✅ Complete | 최종 디자인 반영해서 수정하기 |
| 온보딩 페이지 마이페이지 추가 | 온보딩에서 받아온 정보를 마이페이지에서 수정할 수 있게 데이터 연동 및 디자인 구성 | ✅ Complete | |
| 앱 UI 리디자인 (1) — 전체 UI | 카드 교환 앱에 맞는 전반적인 디자인으로 수정 | ✅ Complete | |
| 앱 UI 리디자인 (2) — 디테일 수정 | 딕셔너리뷰 sort, 커스텀 탭바 변경, 카드 상세 360도 회전 | ✅ Complete | |
| API 연결해서 적용하기 | MapKit으로 카드를 교환한 지점을 지도 위에 표시 | ✅ Complete | |

---

# 🖥️ 화면별 기능 명세

## 1. OnboardingView
> 사용자가 본인의 정보를 입력할 수 있는 페이지

| 컴포넌트 | 설명 |
|----------|------|
| 이미지 피커 | 사용자 이미지를 선택하고 표시 |
| 텍스트 필드 | 닉네임, 한 줄 소개 입력 |
| 버튼 | 오전 / 오후 세션 선택 |

---

## 2. HomeView
> 사용자의 카드 & 상대방 카드 교환 페이지로 이동 가능

<img src="./screenshots/home.png" width="240"/> <img src="./screenshots/home_tabbar.png" width="240"/>

| 컴포넌트 | 설명 |
|----------|------|
| 이미지 | 사용자 프로필 이미지 표시 |
| 텍스트 | 카드를 눌러 교환할 수 있도록 안내 멘트 |
| 커스텀 탭바 | 홈 / 도감 페이지로 이동 |

### 2-1. CardSwapView (Modal)
> 상대방과 카드를 교환할 수 있는 페이지

<img src="./screenshots/cardswap_searching.png" width="240"/>

| 컴포넌트 | 설명 |
|----------|------|
| 이미지 | 사용자 본인의 카드 표시 |
| 애니메이션 효과 | 카드가 빙글빙글 돌면서 상대방 카드를 탐색 |
| MultipeerConnectivity | Apple 프레임워크로 Wi-Fi / Bluetooth를 통해 기기 간 통신. 상대방과 카드 교환 후 수집한 카드는 DictionaryView에 저장 |
| 텍스트 (상태 안내) | 1. 연결 중 — "주변에 있는 러너들을 찾고 있어요!" <br> 2. 연결 됨 — "러너를 발견했어. 스와이프를 통해 카드를 전송해!" <br> 3. 교환 됨 — "아카데미 러너 OOO을 얻었다!" |
| 버튼 | 닫기 버튼 / 저장하기 버튼 |

---

## 3. DictionaryView
> 사용자 정보 확인 & 수집 현황 & 수집한 카드 목록 & 카드 상세 정보 확인

<img src="./screenshots/dictionary.png" width="240"/>

| 컴포넌트 | 설명 |
|----------|------|
| 텍스트 | "러너 도감" 타이틀 표시 |
| 마이프로필 버튼 | 사용자 정보가 담긴 마이프로필로 이동 |
| 게이지바 | 전체 수집 현황 & 오전 세션 & 오후 세션 구분 표시 |
| 필터링바 | 각 필터링 내용별로 카드 분류 표시 |
| 그리드 | 수집한 카드가 순서대로 등록 |

### 3-1. MyProfileView (Modal)
> 사용자 본인의 정보를 확인하고 수정할 수 있는 페이지

<img src="./screenshots/myprofile.png" width="240"/>

| 컴포넌트 | 설명 |
|----------|------|
| 컴포넌트 구성 | OnboardingView와 동일한 구성 |

### 3-2. CardView (Modal)
> 카드 상세 정보를 볼 수 있는 페이지

<img src="./screenshots/card_front.png" width="240"/> <img src="./screenshots/card_back.png" width="240"/>

| 컴포넌트 | 설명 |
|----------|------|
| 이미지 | 상대방 정보가 담긴 카드 상세 정보 확인 |
| DragGesture | 카드를 360도로 돌려가며 상세 정보 확인 |
| 텍스트 | "카드를 좌우로 돌려봐!" |
| 버튼 | 닫기 버튼 |

---

## 4. JidoView
> 카드를 교환했던 위치를 확인할 수 있는 페이지

<img src="./screenshots/jido.png" width="240"/> <img src="./screenshots/jido_list.png" width="240"/>

| 컴포넌트 | 설명 |
|----------|------|
| MapKit | 지도 표시 및 특정 좌표에 핀 마킹 |
| 이미지 버튼 | 해당 위치 버튼 탭 시 교환한 카드 상세 정보 조회. 동일 위치에 여러 카드가 있으면 리스트로 표시 후 각 카드 상세 접근 가능 |
