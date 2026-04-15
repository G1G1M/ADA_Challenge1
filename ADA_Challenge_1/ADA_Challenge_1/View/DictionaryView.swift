import SwiftUI
import SwiftData

struct DictionaryView: View {
    
    @State var isSelectedCard: Bool = false // 모달을 보여줄지 말지
    @State var selectedLearner: Learner? = nil // 어떤 카드를 보여줄지 (LearnerModel로 변경)
    @Query(sort: \Learner.order) private var learners: [Learner] // @Binding 대신 @Query로 SwiftData에서 직접 읽어옴
    
    let columns = Array(repeating: GridItem(.flexible(), spacing: 7), count: 5) // 반복문으로 한줄로 줄임
    
    private var collectedCount: Int { // 수집한 러너 수
        learners.filter { $0.imageData != nil }.count // 호출될 때마다 계산됨
    }
    
    var body: some View {
        
        NavigationStack {
            ZStack {
                VStack(spacing: 0) {
                    
                    HStack(spacing: 0) {
                        Text("Dict")
                            .font(.system(size: 28, weight: .bold, design: .default))
                            .padding(.top, 13)
                            .padding(.bottom, 32)
                            .padding(.leading, 30)
                            .padding(.trailing, 14)
                        
                        Text("\(collectedCount)/180")
                            .font(.system(size: 16, weight: .bold, design: .default))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 13)
                            .padding(.bottom, 32)
                    }
                    
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 0) { // 메모리 효율적으로 관리
                            ForEach(learners) { learner in
                                ZStack {
                                    RoundedRectangle(cornerRadius: 3)
                                        .fill(Color.gray.opacity(0.3))
                                        .aspectRatio(3/4, contentMode: .fit) // 카드 가로 세로 비율 고정
                                    
                                    if let imageData = learner.imageData { // imagePath 대신 imageData 사용
                                        if let uiImage = UIImage(data: imageData) { // Data에서 UIImage 생성
                                            Image(uiImage: uiImage)
                                                .resizable()
                                                .aspectRatio(3/4, contentMode: .fit) // 카드 가로 세로 비율 고정
                                                .clipShape(RoundedRectangle(cornerRadius: 3))
                                        }
                                    } else {
                                        Image(systemName: "apple.logo")
                                            .resizable()
                                            .frame(width: 30, height: 30)
                                            .foregroundStyle(.gray)
                                    }
                                }
                                .padding(.bottom, 7)
                                .onTapGesture {
                                    withAnimation(.easeInOut(duration: 0.2)) { // 처음과 끝은 느리게, 중간은 빠르게
                                        selectedLearner = learner
                                        isSelectedCard = true
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
                
                // 카드 선택됐을 때
                if isSelectedCard {
                    // 배경 blur
                    Color.black.opacity(0.5)
                        .ignoresSafeArea()
                    
                    // 카드뷰
                    if let learner = selectedLearner {
                        CardView(learner: learner, onClose: {
                            selectedLearner = nil // 선택 초기화
                            isSelectedCard = false // 모달 닫힘
                        })
                    }
                }
            }
            .toolbar(isSelectedCard ? .hidden : .visible, for: .tabBar) // 모달 화면에서 tabBar 안보이게
        }
    }
}
