import SwiftUI
import SwiftData

struct DictionaryView: View {
    
    @State var isSelectedCard: Bool = false // 모달을 보여줄지 말지
    @State var selectedLearner: Learner? = nil // 어떤 카드를 보여줄지 (LearnerModel로 변경)
    @Query(sort: \Learner.order) private var learners: [Learner] // @Binding 대신 @Query로 SwiftData에서 직접 읽어옴
    
    @State private var showMyProfile: Bool = false // 마이프로필뷰 모달 표시 여부
    @Query private var profiles: [MyProfile]
    
    let columns = Array(repeating: GridItem(.flexible(), spacing: 7), count: 5) // 반복문으로 한줄로 줄임
    
    private var collectedCount: Int { // 수집한 러너 수
        learners.filter { $0.imageData != nil }.count // 호출될 때마다 계산됨
    }
    
    private var morningCount: Int { // 오전 분반 러너 수
        learners.filter { $0.imageData != nil && $0.time == "오전" }.count // 호출될 때마다 계산됨
    }
    
    private var afternoonCount: Int { // 오후 분반 러너 수
        learners.filter { $0.imageData != nil && $0.time == "오후" }.count // 호출될 때마다 계산됨
    }
    
    var body: some View {
        // 모달이 화면 전체를 덮음
        ZStack {
            VStack {
                // 커스텀 헤더 (타이틀 + 마이프로필 버튼)
                HStack {
                    Text("러너 도감")
                        .font(.system(size: 20, weight: .semibold))
                    Spacer()
                    Button {
                        showMyProfile = true
                    } label: {
                        if let data = profiles.first?.imageData,
                           let uiImage = UIImage(data: data) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 32, height: 32)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.black.opacity(0.3), lineWidth: 1))
                        } else {
                            Image(systemName: "person.circle")
                                .font(.system(size: 22))
                                .foregroundStyle(.gray)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)

                // 게이지 바 (프로그레스바 + 오전/오후 뱃지)
                HStack(spacing: 10) {
                    Text("\(collectedCount)/180")
                        .font(.system(size: 12))
                        .foregroundStyle(.gray)

                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 99)
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 5)
                            RoundedRectangle(cornerRadius: 99)
                                .fill(Color.red)
                                .frame(width: geo.size.width * CGFloat(collectedCount) / 180, height: 5)
                        }
                    }
                    .frame(height: 5)

                    // 오전 뱃지
                    Text("오전 \(morningCount)")
                        .font(.system(size: 11))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.2))
                        .foregroundStyle(.blue)
                        .clipShape(Capsule())

                    // 오후 뱃지
                    Text("오후 \(afternoonCount)")
                        .font(.system(size: 11))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.yellow.opacity(0.4))
                        .foregroundStyle(Color(hex: "8B6914"))
                        .clipShape(Capsule())
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)

                Divider()

                // 그리드
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 0) {
                        ForEach(learners) { learner in
                            ZStack {
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(Color.gray.opacity(0.3))
                                    .aspectRatio(3/4, contentMode: .fit)

                                if let imageData = learner.imageData,
                                   let uiImage = UIImage(data: imageData) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .aspectRatio(3/4, contentMode: .fit)
                                        .clipShape(RoundedRectangle(cornerRadius: 3))
                                } else {
                                    Image(systemName: "apple.logo")
                                        .resizable()
                                        .frame(width: 30, height: 30)
                                        .foregroundStyle(.gray)
                                }
                            }
                            .padding(.bottom, 7)
                            .onTapGesture {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    selectedLearner = learner
                                    isSelectedCard = true
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
            .background(Color(hex: "FFFFFF").ignoresSafeArea())

            // 모달을 바깥 ZStack으로 빼서 화면 전체를 덮음
            if isSelectedCard {
                Color.black.opacity(0.5)
                    .ignoresSafeArea()

                if let learner = selectedLearner {
                    CardView(learner: learner, onClose: {
                        selectedLearner = nil
                        isSelectedCard = false
                    })
                }
            }
        }
        .toolbar(isSelectedCard ? .hidden : .visible, for: .tabBar)
        .fullScreenCover(isPresented: $showMyProfile) {
            MyProfileView()
        }
    }
}

#Preview {
    DictionaryView()
        .modelContainer(for: Learner.self, inMemory: true)
}
