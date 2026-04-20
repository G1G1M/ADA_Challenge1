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
    @State private var showDropdown: Bool = false // 드롭다운 표시 여부
    
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
    
    // 타이틀 텍스트 (선택된 필터에 따라 바뀜)
    private var currentTitle: String {
        switch selectedFilter {
        case "오전": return "오전 세션"
        case "오후": return "오후 세션"
        default: return "러너 도감"
        }
    }
    
    private var filteredLearners: [Learner] {
        guard let filter = selectedFilter else { return learners } // nil이면 전체 반환
        return learners.filter { $0.time == filter && $0.imageData != nil } // 선택된 필터 + 수집한 것만
    }
    
    var body: some View {
        ZStack {
            VStack {
                // 커스텀 헤더 (타이틀 드롭다운 + 마이프로필 버튼)
                HStack {
                    // 타이틀 드롭다운 버튼
                    Button {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            showDropdown.toggle()
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Text(currentTitle)
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundStyle(Color.primary)
                            
                            Image(systemName: "chevron.down")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(Color.gray)
                                .rotationEffect(.degrees(showDropdown ? 180 : 0))
                        }
                    }
                    
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
                
                // 드롭다운 리스트 (타이틀 바로 아래에서 인라인으로 펼쳐짐)
                if showDropdown {
                    VStack(spacing: 0) {
                        // 전체
                        Button {
                            selectedFilter = nil
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) { showDropdown = false }
                        } label: {
                            HStack {
                                Text("전체")
                                    .font(.system(size: 16))
                                    .foregroundStyle(Color.primary)
                                Spacer()
                                if selectedFilter == nil {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundStyle(.blue)
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                        }
                        
                        Divider().padding(.horizontal, 20)
                        
                        // 오전 세션
                        Button {
                            selectedFilter = "오전"
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) { showDropdown = false }
                        } label: {
                            HStack {
                                Text("오전 세션")
                                    .font(.system(size: 16))
                                    .foregroundStyle(Color.primary)
                                Spacer()
                                if selectedFilter == "오전" {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundStyle(.blue)
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                        }
                        
                        Divider().padding(.horizontal, 20)
                        
                        // 오후 세션
                        Button {
                            selectedFilter = "오후"
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) { showDropdown = false }
                        } label: {
                            HStack {
                                Text("오후 세션")
                                    .font(.system(size: 16))
                                    .foregroundStyle(Color.primary)
                                Spacer()
                                if selectedFilter == "오후" {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundStyle(.blue)
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                        }
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }

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
                        .font(.system(size: 11, weight: selectedFilter == "오전" ? .bold : .regular))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(selectedFilter == "오전" ? Color.blue : Color.blue.opacity(0.2))
                        .foregroundStyle(selectedFilter == "오전" ? .white : .blue)
                        .clipShape(Capsule())
                        .onTapGesture {
                            selectedFilter = selectedFilter == "오전" ? nil : "오전"
                        }

                    // 오후 뱃지
                    Text("오후 \(afternoonCount)")
                        .font(.system(size: 11, weight: selectedFilter == "오후" ? .bold : .regular))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(selectedFilter == "오후" ? Color(hex: "8B6914") : Color.yellow.opacity(0.4))
                        .foregroundStyle(selectedFilter == "오후" ? .white : Color(hex: "8B6914"))
                        .clipShape(Capsule())
                        .onTapGesture {
                            selectedFilter = selectedFilter == "오후" ? nil : "오후"
                        }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)

                Divider()

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
