import SwiftUI
import SwiftData

struct TabBarView: View {
    
    @State private var showSplash: Bool = true
    @State private var currentTab: String = "홈"
    @State private var hideTabBar: Bool = false
    
    var body: some View {
        ZStack {
            // 메인 콘텐츠 레이어
            // 화면을 파괴하지 않고 숨겨만 두어 반짝임을 방지
            Group {
                HomeView()
                    .opacity(currentTab == "홈" ? 1 : 0)
                
                DictionaryView(hideTabBar: $hideTabBar)
                    .opacity(currentTab == "도감" ? 1 : 0)
                
                SettingView()
                    .opacity(currentTab == "설정" ? 1 : 0)
            }
            // 화면 전환 애니메이션을 빼거나 아주 짧게 주어 즉각적인 반응을 유도
            .animation(nil, value: currentTab)
            
            // 탭바 레이어
            VStack {
                Spacer()
                CardTabBar(nowTabState: $currentTab)
            }
            .opacity(hideTabBar ? 0 : 1)
            .animation(.easeInOut(duration: 0.2), value: hideTabBar)
            .ignoresSafeArea(.keyboard) // 키보드 대응
            
            // 스플래시 레이어
            if showSplash {
                SplashView()
                    .transition(.opacity) // 사라질 때 부드럽게
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    showSplash = false
                }
            }
        }
        .preferredColorScheme(.light)
    }
}

#Preview {
    TabBarView()
        .modelContainer(for: [MyProfile.self, Learner.self], inMemory: true)
}
