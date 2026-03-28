import SwiftUI

// 카드 앞면
struct CardView: View {
    let runner: Runner // DictionaryView에서 선택된 runner를 받아옴
    var onClose: () -> Void // x 버튼
    @State var isFlipped: Bool = false // 앞면 뒷면 터치
    @StateObject private var gyro = GyroscopeManager()  // 홀로그램 카드 효과
    
    var body: some View {
        
        VStack(spacing: 0) {
            if isFlipped {
                CardBackView(runner: runner)  // 뒷면
                    .onTapGesture {
                        isFlipped.toggle()
                    }
            } else {
                // 교체
                if let imageName = runner.imageName {
                    HologramCardView(imageName: imageName)  // ← 교체!
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
            if runner.imageName != nil {
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
                    .foregroundStyle(.white)
            }
        }
    }
}

//#Preview {
//    CardView(runner: Runner(name: "ian", imageName: "ian", time: "오전", introduce: "안녕하세요 반갑습니다 :)"))
//}
