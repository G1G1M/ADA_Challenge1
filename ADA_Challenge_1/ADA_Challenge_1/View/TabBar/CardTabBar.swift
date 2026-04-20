// 커스텀 카드 탭바.........
import SwiftUI

struct CardTabBar: View {
    @State private var onSwitch: Bool = false
    @Binding var nowTabState: String
    
    var body: some View {
        ZStack {
            // 펼쳐진 상태의 버튼들
            Group {
                // 홈
                tabButton(title: "홈", icon: "house.fill", color: .white)
                    .offset(x: onSwitch ? -85 : 0, y: onSwitch ? -15 : 0)
                    .rotationEffect(.degrees(onSwitch ? -10 : 0))
                    .opacity(onSwitch ? 1 : 0)
                    .onTapGesture { selectTab("홈") }
                    .animation(.spring(response: 0.4, dampingFraction: 0.6).delay(0.05), value: onSwitch)
                
                // 설정
                tabButton(title: "설정", icon: "gearshape.fill", color: .white)
                    .offset(x: onSwitch ? 85 : 0, y: onSwitch ? -15 : 0)
                    .rotationEffect(.degrees(onSwitch ? 10 : 0))
                    .opacity(onSwitch ? 1 : 0)
                    .onTapGesture { selectTab("설정") }
                    .animation(.spring(response: 0.4, dampingFraction: 0.6).delay(0.1), value: onSwitch)
                
                // 도감
                tabButton(title: "도감", icon: "book.fill", color: .white)
                    .offset(x: 0, y: onSwitch ? -35 : 0)
                    .opacity(onSwitch ? 1 : 0)
                    .onTapGesture { selectTab("도감") }
                    .animation(.spring(response: 0.4, dampingFraction: 0.6).delay(0), value: onSwitch)
            }
            
            // 메인 애플 버튼
            mainAppleButton
                .opacity(onSwitch ? 0 : 1) // 켜지면 투명해짐
                .scaleEffect(onSwitch ? 0.5 : 1) // 사라질 때 작아짐
                .animation(.spring(response: 0.4, dampingFraction: 0.6), value: onSwitch)
                .allowsHitTesting(!onSwitch) // 투명해졌을 때 터치 방지
        }
        .padding(.bottom, 30)
    }
    
    // 개별 탭 버튼 디자인
    @ViewBuilder
    func tabButton(title: String, icon: String, color: Color) -> some View {
        Rectangle()
            .fill(Color(white: 0.2).opacity(0.95))
            .frame(width: 70, height: 90)
            .cornerRadius(12)
            .overlay(
                VStack(spacing: 8) {
                    Image(systemName: icon)
                        .font(.title3)
                        .foregroundColor(color)
                    Text(title)
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
            )
            .shadow(color: .black.opacity(0.3), radius: 5, y: 3)
    }
    
    // 메인 애플 버튼
    var mainAppleButton: some View {
        Button(action: {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                self.onSwitch = true
            }
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(white: 0.75))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(white: 0.85), lineWidth: 1)
                    )
                Image(systemName: "apple.logo")
                    .font(.largeTitle)
                    .foregroundStyle(.white)
            }
            .frame(width: 70, height: 90)
            .shadow(color: .black.opacity(0.3), radius: 6, y: 4)
        }
    }
    
    private func selectTab(_ tab: String) {
        nowTabState = tab
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            onSwitch = false
        }
    }
}
