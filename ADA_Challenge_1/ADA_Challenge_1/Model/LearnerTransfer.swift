import Foundation

// MultipeerConnectivity 전송용 (Codable)
// 경로가 아닌 실제 이미지 Data를 포함
struct LearnerTransfer: Codable {
    let name: String
    let imageData: Data? // 실제 이미지 바이너리
    let time: String
    let introduce: String
}
