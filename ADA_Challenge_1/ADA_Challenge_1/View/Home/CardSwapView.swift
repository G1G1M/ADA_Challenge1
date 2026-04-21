import SwiftUI
import SwiftData
import CoreLocation

// 카드 앞면
struct CardSwapView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<MyProfile> { _ in true }) private var profiles: [MyProfile]
    
    @State private var cardLocation: CGSize = .zero   // 카드의 현재 위치 zero = (0,0)
    @State private var cardChange: Bool = false        // false = 본인 카드, true = 다른 사람 카드
    @State private var isRotating: Bool = false        // 카드 회전 여부
    @State private var didSendProfile: Bool = false    // 중복 전송 방지 플래그
    @State private var hasConnectedOnce: Bool = false  // 한 번이라도 연결됐으면 true, 절대 false로 안 돌아감
    
    @StateObject var manager = MultipeerManager() // ObservableObject를 view에서 사용할 때 씀
    @StateObject private var locationManager = LocationManager() // 위치 매니저 추가
    
    private var profile: MyProfile? { profiles.first }
    
    // 프로필 전송 함수로 분리 → 중복 전송 방지
    private func trySendProfile() {
        guard manager.isConnected,  // 연결된 상태
              !didSendProfile,      // 아직 전송 안 했을 때
              let profile else { return }
        
        let transfer = LearnerTransfer(
            name: profile.nickname,
            imageData: profile.imageData,
            time: profile.time,
            introduce: profile.introduce
        )
        manager.sendLearner(transfer)
        didSendProfile = true // 전송 완료 플래그 → 중복 전송 차단
    }
    
    @ViewBuilder
    private func cardContent(imageData: Data?) -> some View {
        if let imageData, let uiImage = UIImage(data: imageData) {
            Image(uiImage: uiImage)
                .resizable()
                .frame(width: 300, height: 420)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .hologramEffect()
                .rotation3DEffect(.degrees(isRotating ? 360 : 0), axis: (x: 0, y: 1, z: 0))
                .animation(
                    isRotating
                        ? .linear(duration: 1.0).repeatForever(autoreverses: false)
                        : .default, // 연결되면 .default로 바꿔서 회전 부드럽게 멈춤
                    value: isRotating
                )
                .padding(.bottom, 79)
        } else {
            Color.gray  // 이미지 없을 때
        }
    }
    
    @ViewBuilder
    private var cardImage: some View {
        let displayData = cardChange
            ? manager.receivedLearner?.imageData
            : profile?.imageData
        
        cardContent(imageData: displayData)
            .offset(cardLocation) // cardLocation이 바뀌면 카드 위치가 바뀜
            .gesture(
                // 연결되고 상대 카드를 받은 상태에서만 스와이프 가능
                manager.isConnected && manager.receivedLearner != nil && !cardChange
                ? DragGesture()
                    .onChanged { value in
                        cardLocation = value.translation // 드래그 중
                    }
                    .onEnded { value in                  // 손 땠을 때
                        withAnimation {
                            cardLocation.height = -1000  // 1. 위로 날아감
                        }
                        // DispatchQueue 대신 Swift Concurrency 사용
                        Task {
                            try? await Task.sleep(for: .seconds(1)) // 1초 대기
                            cardChange = true            // 2. 다른 카드로 교체
                            manager.stopDiscovery()      // 새로운 연결만 차단, 기존 세션은 유지
                            cardLocation.height = -1000  // 3. 위에서 대기, zero로 설정하면 중간에 뿅하고 나타나는 효과가 되어버리기 때문.
                            withAnimation {
                                cardLocation = .zero     // 4. 원래 위치로 내려옴
                            }
                        }
                    }
                : nil // 연결 전 또는 상대 카드 수신 전에는 드래그 비활성화
            )
            .onAppear {
                isRotating = true // 카드 회전 시작
            }
    }
    
    var onClose: () -> Void // x 버튼
    var onSave: (LearnerTransfer, Double?, Double?) -> Void // check 버튼, learner 받아서 저장
    
    var body: some View {
        VStack(spacing: 0) {
            
            cardImage
            
            // ✅ isConnected 대신 hasConnectedOnce 사용 → 순간 끊겨도 텍스트 유지
            if !hasConnectedOnce {
                // 한 번도 연결된 적 없음
                Text("주변에 있는 러너들을\n찾고 있어요!")
                    .font(.system(size: 18, weight: .bold, design: .default))
                    .foregroundStyle(Color.gray)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 48)
            } else if cardChange {
                // 카드 교환 완료
                Text("아카데미 러너 \(manager.receivedLearner?.name ?? "")를 얻었다!")
                    .font(.system(size: 18, weight: .bold, design: .default))
                    .foregroundStyle(Color.gray)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 48)
            } else if manager.receivedLearner != nil {
                // 둘 다 수신 완료 → 동시에 같은 텍스트 표시
                Text("러너를 발견했어!\n스와이프로 상대에게 카드를 전송해!")
                    .font(.system(size: 18, weight: .bold, design: .default))
                    .foregroundStyle(Color.gray)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 48)
            } else {
                // 연결은 됐지만 수신 대기 중 → 둘 다 이 텍스트
                Text("상대방 카드를\n가져오고 있어요...")
                    .font(.system(size: 18, weight: .bold, design: .default))
                    .foregroundStyle(Color.gray)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 48)
            }
            
            Button {
                if cardChange, let learner = manager.receivedLearner {
                    onSave(
                        learner,
                        locationManager.lastLocation?.coordinate.latitude,
                        locationManager.lastLocation?.coordinate.longitude
                    )
                } else {
                    onClose()
                }
            } label: {
                Text(cardChange ? "저장하기" : "닫기")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 65)
                    .padding(.vertical, 14)
                    .background(cardChange ? Color.black : Color.gray.opacity(0.4))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal, 40)
        }
        .onAppear {
            // onAppear: View가 화면에 나타날 때 딱 한 번 실행
            manager.startAdvertising() // 기기 광고 시작
            manager.startBrowsing()   // 기기 탐색 시작
        }
        // 연결 상태 변경 감지
        .onChange(of: manager.isConnected) { connected in
            if connected {
                hasConnectedOnce = true // ✅ 한 번 연결되면 영구적으로 true, 이후 끊겨도 유지
                isRotating = false      // 연결되면 회전 멈춤
                
                // 연결 햅틱
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
                
                trySendProfile() // 함수로 분리된 전송 (중복 방지)
            }
            // connected = false가 돼도 hasConnectedOnce는 건드리지 않음
        }
        // 연결은 됐는데 SwiftData 로딩이 늦은 경우 대비
        .onChange(of: profile) { _ in
            trySendProfile() // 이미 didSendProfile = true면 내부에서 차단됨
        }
        // 상대 카드 수신 완료 감지
        .onChange(of: manager.receivedLearner) { learner in
            if learner != nil {
                // 수신 완료 햅틱
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
            }
        }
    }
}

#Preview {
    TabBarView()
}
