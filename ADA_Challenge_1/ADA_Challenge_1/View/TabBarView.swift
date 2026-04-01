import SwiftUI

struct TabBarView: View {
    
    @State private var showSplash: Bool = true // Splash는 처음에 보여야 하기 때문에 true
    @State var learners = mockLearners
    
    var body: some View {
        ZStack {
            TabView {
                Tab("HOME", systemImage: "house") {
                    HomeView(learners: $learners)
                }
                
                Tab("DICT", systemImage: "book") {
                    DictionaryView(learners: $learners)
                }
            }
            .tint(.black)
            
            if showSplash {
                SplashView()
            }
        }
        .onAppear { // Data 불러오기
            if let savedData = UserDefaults.standard.data(forKey: "learners") { // Data 꺼내기
                if let savedLearner = try? JSONDecoder().decode([Learner].self, from: savedData) { // 2. 배열로 변환
                    learners = savedLearner // 3. learner에 넣기
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    showSplash = false
                }
            }
        }
        .onChange(of: learners) { oldValue, newValue in // Data 저장하기
            if let data = try? JSONEncoder().encode(newValue) {
                UserDefaults.standard.set(data, forKey: "learners")
            }
        }
        .preferredColorScheme(.light)
    }
}

#Preview {
    TabBarView()
}
