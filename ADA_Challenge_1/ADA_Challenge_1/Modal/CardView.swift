import SwiftUI

// 카드 앞면
struct CardView: View {
    let learner: Learner // DictionaryView에서 선택된 learner를 받아옴, 수정할 필요가 없기에 let으로 받아옴
    var onClose: () -> Void // x 버튼
    @State var isFlipped: Bool = false // false: 앞면, true: 뒷면
    
    var body: some View {
        
        VStack(spacing: 0) {
            if isFlipped {
                CardBackView(learner: learner)  // 뒷면
                    .onTapGesture {
                        isFlipped.toggle() // 탭할 때마다 false <-> true 반복
                    }
            } else {
                // 교체
                if learner.imageData != nil {
                    HologramCardView(imageData: learner.imageData)
                        .padding(.bottom, 79)
                        .onTapGesture {
                            isFlipped.toggle()
                        }
                } else {
                    ZStack {
                        Rectangle()
                            .fill(Color(hex: "FFFFFF"))
                            .frame(width: 300, height: 420)
                            .scaledToFill()
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                        
                        Image(systemName: "apple.logo")
                            .font(.system(size: 120))  // ← 이렇게 크기 조절
                            .foregroundStyle(Color(hex: "7C7C7C"))
                    }
                    .hologramEffect()
                    .padding(.bottom, 79)
                }
                
            }
            
            if learner.imageData != nil {
                Text("터치해서 카드를 뒤집어봐!")
                    .font(.system(size: 23, weight: .bold, design: .default))
                    .foregroundStyle(Color(hex: "FFFFFF"))
                    .padding(.bottom, 79)
            } else {
                Text("아직 친해지지 못한 러너인가봐!")
                    .font(.system(size: 23, weight: .bold, design: .default))
                    .foregroundStyle(Color(hex: "FFFFFF"))
                    .padding(.bottom, 79)
            }
            
            Button { // x 버튼
                onClose()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(Color(hex: "D9D9D9"))
            }
        }
    }
}
