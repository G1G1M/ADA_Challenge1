import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    
    // 모달 화면 상태
    @State private var isSelected: Bool = false
    
    // 카드 사용 설명 문구 애니메이션 효과 변수
    @State private var showText: Double = 1.0 // 초기값 
    
    // SwiftData 쿼리 (부모 View에서 빌려오는 대신 직접 쿼리)
    @Query(filter: #Predicate<MyProfile> { _ in true }) private var profiles: [MyProfile]
    @Query(sort: \Learner.order) private var learners: [Learner]
    
    private var profile: MyProfile? { profiles.first }
    
    private var collectedCount: Int { // 수집한 러너 수
        learners.filter { $0.imageData != nil }.count // 호출될 때마다 계산됨
    }
    
    // 받은 LearnerTransfer를 SwiftData에 저장
    private func addLearner(_ transfer: LearnerTransfer) {
        if let target = learners.first(where: { $0.imageData == nil }) {
            target.name = transfer.name
            target.imageData = transfer.imageData // 실제 이미지 Data 저장
            target.time = transfer.time
            target.introduce = transfer.introduce
            try? modelContext.save()
        }
        isSelected = false
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 닉네임
            Text(profile?.nickname ?? "닉네임")
                .font(.system(size: 28, weight: .bold, design: .default))
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 99)
                .padding(.bottom, 15)
            
            // 마이프로필 버튼(누르면 마이프로필뷰로 이동)
            
            // 본인 카드 이미지
            if let imageData = profile?.imageData,
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 280, height: 372)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .hologramEffect()
                    .padding(.bottom, 26)
                    .onTapGesture {
                        isSelected.toggle()
                    }
            } else {
                Image(systemName: "apple.logo")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundStyle(.gray)
            }
            // 카드 사용 설명 문구
            Text("카드를 눌러서\n러너들과 친해져봐!")
                .font(.system(size: 14, weight: .light, design: .default))
                .foregroundStyle(Color.gray)
                .multilineTextAlignment(.center)
                .opacity(showText)
                // 글자가 보였다 안보였다하는 효과
                .onAppear{ withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) { showText = 0.0 }}
        }
        .padding(.horizontal, 30)
        .fullScreenCover(isPresented: $isSelected) {
            CardSwapView(
                onClose: { isSelected = false },
                onSave: { transfer in addLearner(transfer) }
            )
        }
        
        Spacer()
    }
}

#Preview {
    TabBarView()
}
