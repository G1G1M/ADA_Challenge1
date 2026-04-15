import SwiftUI
import SwiftData

struct TabBarView: View {
    
    @State private var showSplash: Bool = true // Splash는 처음에 보여야 하기 때문에 true
    
    var body: some View {
        ZStack {
            TabView {
                Tab("HOME", systemImage: "house") {
                    HomeView()
                }
                
                Tab("DICT", systemImage: "book") {
                    DictionaryView() // DictionaryView도 @Query로 learners를 직접 읽도록 수정 필요
                }
            }
            .tint(.black)
            
            if showSplash {
                SplashView()
            }
        }
        .onAppear { // SwiftData가 자동으로 데이터를 관리하므로 별도 로딩/저장 코드 불필요
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
