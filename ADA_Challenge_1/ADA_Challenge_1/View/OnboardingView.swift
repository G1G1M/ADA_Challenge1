import SwiftUI
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
    @State var nickname: String = ""
    @State var session: Session = .morning
    @State var introduce: String = ""
    @State var selectedPhoto: PhotosPickerItem? = nil // 선택한 사진 담는 변수
    @State var profileImagePath: String? = nil // 저장된 경로 담는 변수
    
    var onComplete: () -> Void
    
    var body: some View {
        VStack {
            PhotosPicker(selection: $selectedPhoto, matching: .images) {
                Text(profileImagePath == nil ? "프로필 사진 선택" : "사진 선택 됨 ✅")
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
                UserDefaults.standard.set(nickname, forKey: "nickname")
                UserDefaults.standard.set(timeString, forKey: "time")
                UserDefaults.standard.set(introduce, forKey: "introduce")
                UserDefaults.standard.set(true, forKey: "isOnboarded")
                UserDefaults.standard.set(profileImagePath, forKey: "imagePath")
                onComplete()
            }
            .disabled(nickname.isEmpty || introduce.isEmpty)
        }
        .padding(20)
        .onChange(of: selectedPhoto) {
            Task {
                if let data = try? await selectedPhoto?.loadTransferable(type: Data.self) { // loadTransferable: 선택한 사진을 Data로 변환해주는 함수
                    // 여기서 data를 파일로 저장
                    // 1. Documents 폴더 경로
                    let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]

                    // 2. 파일 경로 (닉네임.jpg로 저장)
                    let fileURL = documents.appendingPathComponent("\(nickname).jpg")

                    // 3. 저장
                    try? data.write(to: fileURL)

                    // 4. 경로 저장
                    profileImagePath = fileURL.path
                }
            }
        }
    }
}

#Preview {
    OnboardingView(nickname: "김이안", session: .morning, introduce: "이안안이안", onComplete: {})
}
