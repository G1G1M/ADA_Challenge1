import SwiftUI
import SwiftData

// 카드 앞면
struct CardSwapView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<MyProfile> { _ in true }) private var profiles: [MyProfile]
    
    @State private var cardLocation: CGSize = .zero // 카드의 현재 위치 zero = (0,0)
    @State private var cardChange: Bool = false // false = 본인 카드, true = 다른 사람 카드
    @State private var cardRotation: Double = 0 // 카드 회전 초기위치
    @State private var isSpinning: Bool = true // 카드 회전 여부
    
    
    @StateObject var manager = MultipeerManager() // ObservableObject를 view에서 사용할 때 씀
    
    private var profile: MyProfile? { profiles.first }
    
    // 회전 함수
    func startSpinning() {
        withAnimation(.linear(duration: 1.0).repeatForever(autoreverses: false)) {
            cardRotation = 360
        }
    }
    
    @ViewBuilder
    private func cardContent(imageData: Data?) -> some View {
        if let imageData, let uiImage = UIImage(data: imageData) {
            Image(uiImage: uiImage)
                .resizable()
                .frame(width: 300, height: 420)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .hologramEffect()
                .rotation3DEffect(.degrees(cardRotation), axis: (x: 0, y: 1, z: 0))
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
                DragGesture()
                    .onChanged { value in
                        cardLocation = value.translation // 드래그 중
                    }
                    .onEnded { value in                  // 손 땠을 때
                        withAnimation {
                            cardLocation.height = -1000 // 1. 위로 날아감
                        }
                        // DispatchQueue: 작업을 어느 스레드에서 언제 실행할 지 관리하는 것, main 스레드라서 .main
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { // async: 비동기 실행, after: 특정 시간 이후에 실행
                            if manager.receivedLearner != nil {
                                cardChange = true // 2. 다른 카드로 교체
                            }
                            cardLocation.height = -1000 // 3. 위에서 대기, zero로 설정하면 중간에 뿅하고 나타나는 효과가 되어버리기 때문.
                            withAnimation {
                                cardLocation = .zero // 4. 원래 위치로 내려옴
                            }
                        }
                    }
            )
            .onAppear {
                startSpinning()
            }
    }
    
    
    var onClose: () -> Void // x 버튼
    var onSave: (LearnerTransfer) -> Void // check 버튼, learner 받아서 저장 (LearnerTransfer로 변경)
    
    var body: some View {
        VStack(spacing: 0) {
            //            Text(manager.isConnected ? "연결됨" : "연결중 ..") // 연결 상태 표시 -> 카드 돌아가는 효과로 처리해보기
            //                .font(.system(size: 16))
            //                .foregroundStyle(manager.isConnected ? .green : .gray)
            
            cardImage

            Text(!manager.isConnected ? "주변에 있는 러너들을 찾고 있어요!" : cardChange ? "아카데미 러너 \(manager.receivedLearner?.name ?? "")를 얻었다!" : "\(manager.receivedLearner?.name ?? "")를 발견했어!\n스와이프로 상대에게 카드를 전송해!")
                .font(.system(size: 23, weight: .bold, design: .default))
                .multilineTextAlignment(.center)
                .padding(.bottom, 48)
            
            Button {
                if cardChange, let learner = manager.receivedLearner { // , 를 쓰면 조건 확인이랑 옵셔널 꺼내기를 한 줄에 할 수 있어서 더 안전하고 깔끔
                    onSave(learner)  // 받은 LearnerTransfer 넘겨줌
                } else {
                    onClose()
                }
            } label: {
                Image(systemName: cardChange ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(Color(hex: "D9D9D9"))
            }
        }
        .onAppear(){ // onAppear: View가 화면에 나타날 때 딱 한 번 실행
            manager.startAdvertising() // 기기 광고 시작
            manager.startBrowsing() // 기기 탐색 시작
        }
        .onChange(of: manager.isConnected) { connected in
            if connected {
                // 회전 멈춤
                withAnimation(.spring(response: 0.4, dampingFraction: 0.5)) { // 통통튀는, 반응 속도, 튀는 정도
                    cardRotation = 0
                }
                
                // 햅틱
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
                
                // SwiftData에서 내 프로필을 읽어서 이미지 Data 포함해 전송
                guard let profile else { return }
                let transfer = LearnerTransfer(
                    name: profile.nickname,
                    imageData: profile.imageData, // 실제 이미지 Data 전송!
                    time: profile.time,
                    introduce: profile.introduce
                )
                manager.sendLearner(transfer)
            }
        }
    }
}

#Preview {
    TabBarView()
}
