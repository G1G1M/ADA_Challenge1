import SwiftUI
import SwiftData
import PhotosUI

enum Session {
    case morning // 오전
    case afternoon // 오후
}

struct SessionButton: View { // 반복되는 버튼 코드를 하나의 struct로 분리
    let title: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(title) {
            action()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(isSelected ? color : Color.gray.opacity(0.2))
        .foregroundColor(isSelected ? .white : .gray)
        .cornerRadius(8)
    }
}

struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext // SwiftData
    
    @State var nickname: String = ""
    @State var session: Session = .morning
    @State var introduce: String = ""
    @State var selectedPhoto: PhotosPickerItem? = nil // 선택한 사진 담는 변수
    @State var profileImageData: Data? = nil // 저장된 이미지 Data 담는 변수 (경로 대신 Data 사용)
    
    var onComplete: () -> Void
    
    var body: some View {
        VStack {
            PhotosPicker(selection: $selectedPhoto, matching: .images) {
                Text(profileImageData == nil ? "프로필 사진 선택" : "사진 선택 됨 ✅")
            }
            
            TextField("닉네임을 입력해줘!", text: $nickname)
                .multilineTextAlignment(.center)
                .padding(.bottom, 30)

            HStack {
                SessionButton(title: "오전", color: .blue, isSelected: session == .morning) {
                    session = .morning
                }
                SessionButton(title: "오후", color: .yellow, isSelected: session == .afternoon) {
                    session = .afternoon
                }
            }
            .padding(.bottom, 30)
            
            TextField("한 줄 소개를 입력해줘!", text: $introduce)
                .multilineTextAlignment(.center)
                .padding(.bottom, 30)
            
            Button("완료") {
                let timeString = session == .morning ? "오전" : "오후"
                
                // SwiftData에 프로필 저장 (UserDefaults 대신)
                let profile = MyProfile(
                    nickname: nickname,
                    time: timeString,
                    introduce: introduce,
                    imageData: profileImageData
                )
                modelContext.insert(profile)
                
                // 최초 실행 시 180명 빈 러너 생성
                createDefaultLearners(context: modelContext)
                
                // 명시적으로 저장 (insert만 하면 바로 디스크에 안 쓰일 수 있음)
                try? modelContext.save()
                
                // 온보딩 완료 플래그 (앱 진입점에서 온보딩 여부 판단용)
                UserDefaults.standard.set(true, forKey: "isOnboarded")
                
                onComplete()
            }
            .disabled(nickname.isEmpty || introduce.isEmpty || profileImageData == nil)
        }
        .padding(20)
        .onChange(of: selectedPhoto) {
            Task {
                if let data = try? await selectedPhoto?.loadTransferable(type: Data.self) { // loadTransferable: 선택한 사진을 Data로 변환해주는 함수
                    // 파일로 저장하지 않고 Data를 직접 보관
                    profileImageData = data
                }
            }
        }
    }
}

#Preview {
    OnboardingView(nickname: "김이안", session: .morning, introduce: "이안안이안", onComplete: {})
        .modelContainer(for: [MyProfile.self, Learner.self], inMemory: true)
}
