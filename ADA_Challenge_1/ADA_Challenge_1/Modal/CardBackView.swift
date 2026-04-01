import SwiftUI

// 카드 뒷면
struct CardBackView: View {
    let learner: Learner
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(hex: "BABABA"))
                .frame(width: 300, height: 420)
            
            VStack(spacing: 0) {
                if let imageName = learner.imageName {
                    Image(imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 134, height: 134)
                        .clipShape(Circle())
                        .padding(.bottom, 15)
                }
                
                Text(learner.name)
                    .font(Font.system(size: 20, weight: .bold, design: .default))
                    .padding(.bottom, 5)
                
                ZStack {
                    Capsule()
                        .fill(learner.time == "오전" ? Color(hex: "00D4FF") : Color(hex: "F6FF00"))
                        .frame(width: 43, height: 19)
                    
                    Text(learner.time)
                        .font(Font.system(size: 12, weight: .bold, design: .default))
                        .foregroundStyle(.black)
                        .background(Capsule().fill(learner.time == "오전" ? Color(hex: "00D4FF") : Color(hex: "F6FF00")))
                }
                .padding(.bottom, 21)
                
                Text(learner.introduce)
                    .font(Font.system(size: 12, weight: .bold, design: .default))
                    .foregroundStyle(.black)
            }
        }
        .hologramEffect()
        .padding(.bottom, 79)
    }
}

#Preview {
    CardBackView(learner: Learner(name: "ian", imageName: "Ian", time: "오후", introduce: "안녕하세요 개발하는 ian 입니다 :)"))
}
