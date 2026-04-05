import SwiftUI

struct HomeView: View {
    // 모달 화면 상태
    @State private var isSelected: Bool = false
    @Binding var learners: [Learner] // 부모 View에서 빌려옴
    
    private var collectedCount: Int { // 수집한 러너 수
        learners.filter { $0.imagePath != nil }.count // 호출될 때마다 계산됨
    }
    
    private var morningCount: Int { // 오전 분반 러너 수
        learners.filter { $0.imagePath != nil && $0.time == "오전" }.count // 호출될 때마다 계산됨
    }
    
    private var afternoonCount: Int { // 오후 분반 러너 수
        learners.filter { $0.imagePath != nil && $0.time == "오후" }.count // 호출될 때마다 계산됨
    }
    
    private func addLearner(_ learner: Learner) {
        if let index = learners.firstIndex(where: { $0.imagePath == nil }) {
                learners[index] = learner
            }
            isSelected = false
    }
    
    @AppStorage("nickname") var nickname: String = "닉네임"
    @AppStorage("time") var time: String = "오전"
    @AppStorage("introduce") var introduce: String = ""
    @AppStorage("imagePath") var imagePath: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            
            Text(nickname) // 닉네임
                .font(.system(size: 28, weight: .bold, design: .default))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 13)
                .padding(.bottom, 32)
            
            if let uiImage = UIImage(contentsOfFile: imagePath) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 218, height: 290)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .hologramEffect()
                    .padding(.bottom, 13)
                    .onTapGesture {
                        isSelected.toggle()
                    }
            } else {
                Image(systemName: "apple.logo")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundStyle(.gray)
            }
            
            Text("카드를 눌러서\n러너들과 친해져봐!") // 카드 사용 설명 문구
                .font(.system(size: 14, weight: .light, design: .default))
                .foregroundStyle(Color.gray)
                .multilineTextAlignment(.center)
                .padding(.bottom, 25)
            
            ZStack {
                
                Rectangle() // 진행도 카드
                    .frame(width: 330, height: 198)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                
                VStack(spacing: 0) {
                    HStack {
                        Gauge(value: Double(collectedCount), in: 0...180){} // 러너 수집 현황 게이지(범위)
                        // 인원에 따라 게이지 색상 달라지게 하기
                        currentValueLabel: { // 게이지 중앙에 표시할 뷰(trailing closure)
                            VStack {
                                Text("전체")
                                    .multilineTextAlignment(.center)
                                    .font(.system(size: 7, weight: .light, design: .default))
                                    .foregroundStyle(.black)
                                
                                Text("\(collectedCount)/180")
                                    .multilineTextAlignment(.center)
                                    .font(.system(size: 10, weight: .light, design: .default))
                                    .foregroundStyle(.black)
                            }
                        }
                        .gaugeStyle(.accessoryCircularCapacity) // 원형 게이지 스타일
                        .scaleEffect(1.8) // 1.8배 확대
                        .frame(width: 113, height: 113)
                        .foregroundStyle(Color.white)
                        .tint(.red)
                        .padding(.trailing, 10)
                        
                        VStack {
                            
                            HStack {
                                ZStack { // 오전 러너 수
                                    Capsule()
                                        .fill(Color(hex: "00D4FF"))
                                        .frame(width: 46, height: 32)
                                    
                                    Text("오전")
                                        .font(Font.system(size: 14, weight: .bold, design: .default))
                                        .foregroundStyle(.black)
                                }
                                
                                Text("\(morningCount)/90")
                                    .foregroundStyle(Color.black)
                            }
                            
                            HStack {
                                ZStack { // 오후 러너 수
                                    Capsule()
                                        .fill(Color(hex: "F6FF00"))
                                        .frame(width: 46, height: 32)
                                    
                                    Text("오후")
                                        .font(Font.system(size: 14, weight: .bold, design: .default))
                                        .foregroundStyle(.black)
                                }
                                
                                Text("\(afternoonCount)/90")
                                    .foregroundStyle(Color.black)
                            }
                        }
                    }
                    .padding(.bottom, 16)
                    
                    Text("조금만 더하면 모든 러너들과 친구가 될 수 있어!")
                        .foregroundStyle(.black)
                        .font(Font.system(size: 14, weight: .light, design: .default))
                }
            }
            .foregroundStyle(Color(hex: "F3F3F3"))
        }
        .padding(.horizontal, 30)
        .fullScreenCover(isPresented: $isSelected) {
            CardSwapView(
                onClose: { isSelected = false },
                onSave: { learner in addLearner(learner)}
            )
        }
        
        Spacer()
    }
}

#Preview {
    TabBarView()
}
