import SwiftUI
import MapKit
import SwiftData

// 같은 위치에 있는 러너들을 하나의 그룹으로 묶는 구조체
struct LearnerCluster: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D // 그룹의 대표 좌표
    let learners: [Learner]                // 이 위치에 있는 러너들
}

struct JidoView: View {
    @Query(sort: \Learner.order) private var learners: [Learner] // SwiftData에서 러너 목록 가져옴
    
    @State private var selectedLearner: Learner? = nil      // 카드 모달에 보여줄 러너
    @State private var isSelectedCard: Bool = false         // 카드 모달 표시 여부
    @State private var selectedCluster: LearnerCluster? = nil // 시트에 보여줄 클러스터
    @Binding var hideTabBar: Bool                           // 탭바 숨김 바인딩
    
    // 위치 데이터가 있는 러너만 필터링
    private var learnersWithLocation: [Learner] {
        learners.filter { $0.latitude != nil && $0.longitude != nil }
    }
    
    // 가까운 러너들을 그룹으로 묶기 (50m 이내면 같은 그룹)
    private var clusters: [LearnerCluster] {
        var result: [LearnerCluster] = []
        var used: Set<UUID> = []
        
        for learner in learnersWithLocation {
            guard !used.contains(learner.id) else { continue }
            
            let nearby = learnersWithLocation.filter { other in
                guard !used.contains(other.id) else { return false }
                let loc1 = CLLocation(latitude: learner.latitude!, longitude: learner.longitude!)
                let loc2 = CLLocation(latitude: other.latitude!, longitude: other.longitude!)
                return loc1.distance(from: loc2) <= 50
            }
            
            nearby.forEach { used.insert($0.id) }
            
            result.append(LearnerCluster(
                coordinate: CLLocationCoordinate2D(
                    latitude: learner.latitude!,
                    longitude: learner.longitude!
                ),
                learners: nearby
            ))
        }
        return result
    }
    
    var body: some View {
        ZStack {
            Map {
                ForEach(clusters) { cluster in
                    Annotation("", coordinate: cluster.coordinate) {
                        clusterPin(cluster: cluster)
                    }
                }
            }
            .ignoresSafeArea()
            
            // 카드 모달
            if isSelectedCard, let learner = selectedLearner {
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
                
                CardView(learner: learner, onClose: {
                    selectedLearner = nil
                    isSelectedCard = false
                    hideTabBar = false
                })
            }
        }
        // 클러스터 탭하면 하단 시트로 카드 목록 표시
        .sheet(item: $selectedCluster) { cluster in
            clusterSheet(cluster: cluster)
                .presentationDetents([.fraction(0.4)]) // 화면 40% 높이로 시트 표시
                .presentationDragIndicator(.visible)   // 드래그 인디케이터 표시
        }
    }
    
    // 핀 뷰 (첫 번째 이미지 + 배지)
    @ViewBuilder
    private func clusterPin(cluster: LearnerCluster) -> some View {
        if let imageData = cluster.learners.first?.imageData,
           let uiImage = UIImage(data: imageData) {
            ZStack(alignment: .topTrailing) {
                Image(uiImage: uiImage)
                    .resizable()
                    .frame(width: 44, height: 44)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
                    .shadow(radius: 3)
                
                // 2장 이상이면 배지 표시
                if cluster.learners.count > 1 {
                    Text("+\(cluster.learners.count - 1)")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .background(Color.red)
                        .clipShape(Capsule())
                        .offset(x: 8, y: -8)
                }
            }
            .onTapGesture {
                if cluster.learners.count == 1 {
                    // 1장이면 바로 카드 모달
                    selectedLearner = cluster.learners.first
                    isSelectedCard = true
                    hideTabBar = true
                } else {
                    // 여러 장이면 시트 표시
                    selectedCluster = cluster
                }
            }
        }
    }
    
    // 하단 시트 - 같은 위치의 카드 목록
    @ViewBuilder
    private func clusterSheet(cluster: LearnerCluster) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("이 위치에서 교환한 카드 \(cluster.learners.count)장")
                .font(.system(size: 16, weight: .semibold))
                .padding(.horizontal, 20)
                .padding(.top, 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(cluster.learners) { learner in
                        VStack(spacing: 8) {
                            if let imageData = learner.imageData,
                               let uiImage = UIImage(data: imageData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .aspectRatio(3/4, contentMode: .fill)
                                    .frame(width: 80, height: 107)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                            Text(learner.name)
                                .font(.system(size: 12))
                                .foregroundStyle(.gray)
                        }
                        .onTapGesture {
                            // 카드 탭하면 시트 닫고 모달 오픈
                            selectedCluster = nil
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
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
    }
}

#Preview {
    JidoView(hideTabBar: .constant(false))
        .modelContainer(for: Learner.self, inMemory: true)
}
