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
    @State var profileImageData: Data? = nil // 저장된 이미지 Data 담는 변수
    
    var onComplete: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // 상단 타이틀
            HStack {
                Spacer()
                Text("프로필 설정")
                    .font(.system(size: 16, weight: .semibold))
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            
            Divider()
            
            ScrollView {
                VStack(spacing: 24) {
                    // 이미지 피커
                    PhotosPicker(selection: $selectedPhoto, matching: .images) {
                        if let data = profileImageData, let uiImage = UIImage(data: data) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.gray.opacity(0.3), lineWidth: 1))
                                .overlay(alignment: .bottomTrailing) {
                                    Image(systemName: "pencil.circle.fill")
                                        .font(.system(size: 24))
                                        .foregroundStyle(.black)
                                        .background(Circle().fill(.white))
                                }
                        } else {
                            Circle()
                                .fill(Color.gray.opacity(0.15))
                                .frame(width: 100, height: 100)
                                .overlay(
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 40))
                                        .foregroundStyle(.gray)
                                )
                                .overlay(alignment: .bottomTrailing) {
                                    Image(systemName: "pencil.circle.fill")
                                        .font(.system(size: 24))
                                        .foregroundStyle(.black)
                                        .background(Circle().fill(.white))
                                }
                        }
                    }
                    .padding(.top, 24)
                    
                    // 닉네임 입력
                    VStack(alignment: .leading, spacing: 8) {
                        Text("닉네임")
                            .font(.system(size: 13))
                            .foregroundStyle(.gray)
                        TextField("닉네임을 입력해줘!", text: $nickname)
                            .padding(12)
                            .background(Color.gray.opacity(0.08))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .padding(.horizontal, 20)
                    
                    // 세션 선택
                    VStack(alignment: .leading, spacing: 8) {
                        Text("세션")
                            .font(.system(size: 13))
                            .foregroundStyle(.gray)
                        HStack(spacing: 8) {
                            SessionButton(title: "오전", color: .blue, isSelected: session == .morning) {
                                session = .morning
                            }
                            .scaleEffect(0.85)
                            SessionButton(title: "오후", color: .yellow, isSelected: session == .afternoon) {
                                session = .afternoon
                            }
                            .scaleEffect(0.85)
                            Spacer()
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // 소개글 입력
                    VStack(alignment: .leading, spacing: 8) {
                        Text("한 줄 소개")
                            .font(.system(size: 13))
                            .foregroundStyle(.gray)
                        TextField("한 줄 소개를 입력해줘!", text: $introduce)
                            .padding(12)
                            .background(Color.gray.opacity(0.08))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .padding(.horizontal, 20)
                }
            }
            
            Divider()
            
            // 완료 버튼
            Button {
                let timeString = session == .morning ? "오전" : "오후"
                
                // SwiftData에 프로필 저장
                let profile = MyProfile(
                    nickname: nickname,
                    time: timeString,
                    introduce: introduce,
                    imageData: profileImageData
                )
                modelContext.insert(profile)
                
                // 최초 실행 시 180명 빈 러너 생성
                createDefaultLearners(context: modelContext)
                
                // 명시적으로 저장
                try? modelContext.save()
                
                // 온보딩 완료 플래그
                UserDefaults.standard.set(true, forKey: "isOnboarded")
                
                onComplete()
            } label: {
                Text("완료")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(nickname.isEmpty || introduce.isEmpty || profileImageData == nil ? Color.gray.opacity(0.3) : Color.black)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(nickname.isEmpty || introduce.isEmpty || profileImageData == nil)
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
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
