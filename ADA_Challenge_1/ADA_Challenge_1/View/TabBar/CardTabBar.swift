// 커스텀 카드 탭바.........
import SwiftUI

struct CardTabBar: View {
    @State private var onSwitch: Bool = false
    @Binding var nowTabState: String
    
    private func selectTab(_ tab: String) {
        nowTabState = tab
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            onSwitch = false
        }
    }
    
    var body: some View {
        ZStack {
            Group {
                // 홈
                tabButton(title: "홈", icon: "house.fill", color: .white)
                    .offset(x: onSwitch ? -80 : 0, y: onSwitch ? -75 : 0)
                    .rotationEffect(.degrees(onSwitch ? -8 : 0))
                    .opacity(onSwitch ? 1 : 0)
                    .scaleEffect(onSwitch ? 1 : 0.5)
                    .onTapGesture { selectTab("홈") }
                    .animation(.spring(response: 0.4, dampingFraction: 0.6).delay(0.05), value: onSwitch)

                // 도감
                tabButton(title: "도감", icon: "book.fill", color: .white)
                    .offset(x: 0, y: onSwitch ? -80 : 0)
                    .opacity(onSwitch ? 1 : 0)
                    .scaleEffect(onSwitch ? 1 : 0.5)
                    .onTapGesture { selectTab("도감") }
                    .animation(.spring(response: 0.4, dampingFraction: 0.6).delay(0), value: onSwitch)

                // 설정
                tabButton(title: "지도", icon: "map.fill", color: .white)
                    .offset(x: onSwitch ? 80 : 0, y: onSwitch ? -75 : 0)
                    .rotationEffect(.degrees(onSwitch ? 8 : 0))
                    .opacity(onSwitch ? 1 : 0)
                    .scaleEffect(onSwitch ? 1 : 0.5)
                    .onTapGesture { selectTab("지도") }
                    .animation(.spring(response: 0.4, dampingFraction: 0.6).delay(0.05), value: onSwitch)
            }
            
            // 메인 토글 버튼
            mainToggleButton
        }
    }
    
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
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
            )
            .shadow(color: .black.opacity(0.3), radius: 5, y: 3)
    }
    
    // + 버튼
    var mainToggleButton: some View {
        Button(action: {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                onSwitch.toggle()
            }
        }) {
            ZStack {
                Circle()
                    .fill(onSwitch ? Color(white: 0.75) : Color.black)
                    .frame(width: 55, height: 55)
                    .shadow(color: .black.opacity(0.3), radius: 6, y: 4)
                
                Image(systemName: onSwitch ? "xmark" : "line.3.horizontal")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .rotationEffect(.degrees(onSwitch ? 90 : 0))
            }
            .scaleEffect(onSwitch ? 0.85 : 1.0)
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.6), value: onSwitch)
        .padding(.top, 15)
    }
}
