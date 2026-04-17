import SwiftUI
import SwiftData
import PhotosUI

struct MyProfileView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var profiles: [MyProfile]
    
    @State var nickname: String = ""
    @State var session: Session = .morning
    @State var introduce: String = ""
    @State var selectedPhoto: PhotosPickerItem? = nil
    @State var profileImageData: Data? = nil
    
    var body: some View {
        VStack(spacing: 0) {
            // 마이페이지 상단 (닫기 버튼)
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.gray)
                }
                Spacer()
                Text("내 프로필")
                    .font(.system(size: 16, weight: .semibold))
                Spacer()
                // 좌우 균형 맞추기용 빈 공간
                Image(systemName: "xmark")
                    .font(.system(size: 16))
                    .opacity(0)
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
                        } else {
                            Circle()
                                .fill(Color.gray.opacity(0.15))
                                .frame(width: 100, height: 100)
                                .overlay(
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 40))
                                        .foregroundStyle(.gray)
                                )
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
            
            // 마이페이지 하단
            Divider()
            
            // 변경사항 저장 버튼
            Button {
                if let profile = profiles.first {
                    profile.nickname = nickname
                    profile.introduce = introduce
                    profile.imageData = profileImageData
                    profile.time = session == .morning ? "오전" : "오후"
                    try? modelContext.save() // 써도 되고 안써도 됨
                }
                dismiss()
            } label: {
                Text("저장")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.black)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .onAppear {
            // 기존 저장된 프로필 불러와서 State 변수에 채워주기
            if let profile = profiles.first {
                nickname = profile.nickname
                introduce = profile.introduce
                profileImageData = profile.imageData
                session = profile.time == "오전" ? .morning : .afternoon
            }
        }
        .onChange(of: selectedPhoto) {
            Task {
                if let data = try? await selectedPhoto?.loadTransferable(type: Data.self) {
                    profileImageData = data
                }
            }
        }
    }
}

#Preview {
    MyProfileView()
        .modelContainer(for: [MyProfile.self, Learner.self], inMemory: true)
}
