import SwiftUI
import SwiftData

// 카드 앞면
struct CardSwapView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<MyProfile> { _ in true }) private var profiles: [MyProfile]
    
    @State private var cardLocation: CGSize = .zero // 카드의 현재 위치 zero = (0,0)
    @State private var cardChange: Bool = false // false = 본인 카드, true = 다른 사람 카드
    @State private var isRotating: Bool = false // 카드 회전 여부
        
    @StateObject var manager = MultipeerManager() // ObservableObject를 view에서 사용할 때 씀
    
    private var profile: MyProfile? { profiles.first }
    
    @ViewBuilder
    private func cardContent(imageData: Data?) -> some View {
        if let imageData, let uiImage = UIImage(data: imageData) {
            Image(uiImage: uiImage)
                .resizable()
                .frame(width: 300, height: 420)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .hologramEffect()
                .rotation3DEffect(.degrees(isRotating ? 360 : 0), axis: (x: 0, y: 1, z: 0))
                .animation(.linear(duration: 1.0).repeatForever(autoreverses: false), value: isRotating) // withAnimation 대신 .animation으로 간섭 방지
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
                isRotating = true // 카드 회전 시작
            }
    }
    
    var onClose: () -> Void // x 버튼
    var onSave: (LearnerTransfer) -> Void // check 버튼, learner 받아서 저장 (LearnerTransfer로 변경)
    
    var body: some View {
        VStack(spacing: 0) {
            
            cardImage

            if !manager.isConnected {
                Text("주변에 있는 러너들을\n찾고 있어요!")
                    .font(.system(size: 18, weight: .bold, design: .default))
                    .foregroundStyle(Color.gray)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 48)
            } else if cardChange {
                Text("아카데미 러너 \(manager.receivedLearner?.name ?? "")를 얻었다!")
                    .font(.system(size: 18, weight: .bold, design: .default))
                    .foregroundStyle(Color.gray)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 48)
            } else {
                Text("\(manager.receivedLearner?.name ?? "")를 발견했어!\n스와이프로 상대에게 카드를 전송해!")
                    .font(.system(size: 18, weight: .bold, design: .default))
                    .foregroundStyle(Color.gray)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 48)
            }
            
            Button {
                if cardChange, let learner = manager.receivedLearner { // , 를 쓰면 조건 확인이랑 옵셔널 꺼내기를 한 줄에 할 수 있어서 더 안전하고 깔끔
                    onSave(learner)  // 받은 LearnerTransfer 넘겨줌
                } else {
                    onClose()
                }
            } label: {
                Text(cardChange ? "저장하기" : "닫기")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 50)
                    .padding(.vertical, 14)
                    .background(cardChange ? Color.black : Color.gray.opacity(0.4))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal, 40)
        }
        .onAppear() { // onAppear: View가 화면에 나타날 때 딱 한 번 실행
            manager.startAdvertising() // 기기 광고 시작
            manager.startBrowsing() // 기기 탐색 시작
        }
        .onChange(of: manager.isConnected) { connected in
            if connected {
                // 회전 멈춤
                isRotating = false
                
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
