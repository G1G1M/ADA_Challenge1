import SwiftUI

struct OnboardingView: View {
    @State var nickname: String = ""
    @State var time: String = "오전"
    @State var introduce: String = ""
    
    var onComplete: () -> Void
    
    var body: some View {
        VStack {
            TextField("닉네임을 입력해줘!", text: $nickname)
            
            HStack {
                Button("오전") {
                    time = "오전"
                }
                Button("오후") {
                    time = "오후"
                }
            }
            
            TextField("한 줄 소개를 입력해줘!", text: $introduce)
            
            Button("완료") {
                UserDefaults.standard.set(nickname, forKey: "nickname")
                UserDefaults.standard.set(time, forKey: "time")
                UserDefaults.standard.set(introduce, forKey: "introduce")
                UserDefaults.standard.set(true, forKey: "isOnboarded")
                onComplete() // 화면 닫기
            }
            
        }
    }
}

#Preview {
    OnboardingView(nickname: "노숭이", time: "오전", introduce: "북치기 닭볶음탕!", onComplete: {})
}
