import SwiftUI
import SwiftData

@main
struct ADA_Challenge_1App: App {
    @State var isOnboarded: Bool = UserDefaults.standard.bool(forKey: "isOnboarded") // UserDefaults에서 isOnboarded 꺼내기
    
    var body: some Scene {
        WindowGroup {
            if isOnboarded {
                TabBarView()
                    .preferredColorScheme(.light)
            } else {
                OnboardingView(onComplete: {
                    isOnboarded = true
                })
            }
        }
        .modelContainer(for: [MyProfile.self, Learner.self]) // SwiftData 데이터베이스 생성 + 하위 모든 View에 modelContext 주입
    }
}
