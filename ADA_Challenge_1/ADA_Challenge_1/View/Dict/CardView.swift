import SwiftUI

// 카드 앞면
struct CardView: View {
    let learner: Learner // DictionaryView에서 선택된 learner를 받아옴
    var onClose: () -> Void // x 버튼
    
    // 제스처를 위한 상태값 추가
    @State private var rotationAngle: Double = 0.0
    @State private var draggedAngle: Double = 0.0
    
    // 카드 크기 상수화
    private let cardWidth: CGFloat = 300
    private let cardHeight: CGFloat = 420
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                // 뒷면 (180도 부근에서 활성화)
                CardBackView(learner: learner)
                    .frame(width: cardWidth, height: cardHeight) // 크기 고정
                    .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                    .opacity(abs(rotationAngle).truncatingRemainder(dividingBy: 360) > 90 && abs(rotationAngle).truncatingRemainder(dividingBy: 360) < 270 ? 1 : 0)

                // 앞면 (0도 부근에서 활성화)
                Group {
                    if learner.imageData != nil {
                        HologramCardView(imageData: learner.imageData)
                    } else {
                        placeholderFrontView
                    }
                }
                .frame(width: cardWidth, height: cardHeight) // 크기 고정
                .opacity(abs(rotationAngle).truncatingRemainder(dividingBy: 360) <= 90 || abs(rotationAngle).truncatingRemainder(dividingBy: 360) >= 270 ? 1 : 0)
            }
            // 회전 효과를 패딩보다 먼저 적용하여 중앙 축 유지
            .rotation3DEffect(.degrees(rotationAngle), axis: (x: 0, y: 1, z: 0), perspective: 0.5)
            .padding(.bottom, 79)
            // 드래그 회전 제스처
            .gesture(
                DragGesture()
                    .onChanged { value in
                        rotationAngle = draggedAngle + value.translation.width * 0.8
                    }
                    .onEnded { value in
                        let snapAngle = round(rotationAngle / 180) * 180
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                            rotationAngle = snapAngle
                        }
                        draggedAngle = rotationAngle
                    }
            )
            
            // 안내 문구
            Text(learner.imageData != nil ? "카드를 좌우로 돌려봐!" : "아직 친해지지 못한 러너인가봐!")
                .font(.system(size: 23, weight: .bold))
                .foregroundStyle(.white)
                .padding(.bottom, 79)
            
            Button { // x 버튼
                onClose()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(Color(hex: "D9D9D9"))
            }
        }
    }
    
    private var placeholderFrontView: some View {
        ZStack {
            Rectangle()
                .fill(Color(white: 1.0))
                .frame(width: 300, height: 420)
                .clipShape(RoundedRectangle(cornerRadius: 20))
            Image(systemName: "apple.logo")
                .font(.system(size: 120))
                .foregroundStyle(Color(hex: "7C7C7C"))
        }
        .hologramEffect()
    }
}
