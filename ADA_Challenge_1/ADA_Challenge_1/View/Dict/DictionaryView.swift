import SwiftUI
import SwiftData

struct DictionaryView: View {
    
    @State var isSelectedCard: Bool = false // 모달을 보여줄지 말지
    @State var selectedLearner: Learner? = nil // 어떤 카드를 보여줄지
    @Query(sort: \Learner.order) private var learners: [Learner] // @Binding 대신 @Query로 SwiftData에서 직접 읽어옴
    
    @State private var showMyProfile: Bool = false // 마이프로필뷰 모달 표시 여부
    @Query private var profiles: [MyProfile]
    
    @Binding var hideTabBar: Bool // 탭바 숨김 상태 바인딩
    @State private var selectedFilter: String? = nil // nil = 전체, "오전" or "오후"
    @Namespace private var filterNamespace // 슬라이딩 언더라인 애니메이션용
    
    let columns = Array(repeating: GridItem(.flexible(), spacing: 7), count: 5) // 반복문으로 한줄로 줄임
    
    private var collectedCount: Int { // 수집한 러너 수
        learners.filter { $0.imageData != nil }.count // 호출될 때마다 계산됨
    }
    
    private var morningCount: Int { // 오전 분반 러너 수
        learners.filter { $0.imageData != nil && $0.time == "오전" }.count
    }
    
    private var afternoonCount: Int { // 오후 분반 러너 수
        learners.filter { $0.imageData != nil && $0.time == "오후" }.count
    }
    
    private var filteredLearners: [Learner] {
        guard let filter = selectedFilter else { return learners } // nil이면 전체 반환
        return learners.filter { $0.time == filter && $0.imageData != nil } // 선택된 필터 + 수집한 것만
    }
    
    var body: some View {
        ZStack {
            VStack {
                // 커스텀 헤더 (타이틀 텍스트 + 마이프로필 버튼)
                HStack {
                    Text("러너 도감")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(Color.primary)
                    
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

                // 게이지 바
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
                        .font(.system(size: 11, weight: .regular))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.2))
                        .foregroundStyle(.blue)
                        .clipShape(Capsule())

                    // 오후 뱃지
                    Text("오후 \(afternoonCount)")
                        .font(.system(size: 11, weight: .regular))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.yellow.opacity(0.4))
                        .foregroundStyle(Color(hex: "8B6914"))
                        .clipShape(Capsule())
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)

                Divider()

                // 필터 버튼
                HStack(spacing: 0) {
                    ForEach(["전체", "오전", "오후"], id: \.self) { option in
                        let isSelected = (option == "전체" && selectedFilter == nil) ||
                                         (option != "전체" && selectedFilter == option)
                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedFilter = option == "전체" ? nil : option
                            }
                        } label: {
                            VStack(spacing: 6) {
                                Text(option)
                                    .font(.system(size: 15, weight: isSelected ? .bold : .regular))
                                    .foregroundStyle(isSelected ? Color.primary : Color.gray)

                                ZStack {
                                    Rectangle()
                                        .fill(Color.clear)
                                        .frame(height: 2)
                                    if isSelected {
                                        Rectangle()
                                            .fill(Color.primary)
                                            .frame(height: 2)
                                            .matchedGeometryEffect(id: "underline", in: filterNamespace)
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                    }
                    Spacer()
                }
                .padding(.horizontal, 4)
                .padding(.top, 4)

                // 그리드
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 0) {
                        ForEach(filteredLearners) { learner in
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
                                    hideTabBar = true
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
            .background(Color(hex: "FFFFFF").ignoresSafeArea())

            // 카드 모달
            if isSelectedCard {
                Color.black.opacity(0.5)
                    .ignoresSafeArea()

                if let learner = selectedLearner {
                    CardView(learner: learner, onClose: {
                        selectedLearner = nil
                        isSelectedCard = false
                        hideTabBar = false
                    })
                }
            }
        }
        .fullScreenCover(isPresented: $showMyProfile) {
            MyProfileView()
        }
    }
}

#Preview {
    DictionaryView(hideTabBar: .constant(false))
        .modelContainer(for: Learner.self, inMemory: true)
}
