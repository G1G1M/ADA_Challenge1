import Foundation
import SwiftData

@Model
class Learner { // Codable 역할은 LearnerTransfer가 담당, Equatable은 @Model이 자동 제공
    var id = UUID() // 고정된 값이 아닌 디코딩할 때 값을 넣기 위해 var로 변경
    var name: String
    @Attribute(.externalStorage) var imageData: Data? // imagePath 대신 imageData 사용
    var time: String
    var introduce: String
    var order: Int // 정렬 순서 유지용
    var latitude: Double? = nil  // 위도 (교환한 위치)
    var longitude: Double? = nil // 경도 (교환한 위치)
    
    init(name: String, imageData: Data? = nil, time: String, introduce: String, order: Int = 0, latitude: Double? = nil, longitude: Double? = nil) {
        self.name = name
        self.imageData = imageData
        self.time = time
        self.introduce = introduce
        self.order = order
        self.latitude = latitude
        self.longitude = longitude
    }
}

let imageNames = ["Jiwoo", "Carmen", "Yuha", "Stella",
                  "Juun", "Ana", "Ian", "Yeon"]

// 최초 실행 시 180명 빈 러너 생성 (서버 없이 사용할 임시 데이터)
func createDefaultLearners(context: ModelContext) {
    for index in 0..<180 { // map 대신 for문으로 SwiftData에 insert
        let name = index < 8 ? imageNames[index % 8] : "Learner \(index)"
        let time = index % 2 == 0 ? "오전" : "오후"
        let introduce = "안녕하세요 \(name) 입니다 :)"
        let learner = Learner(name: name, time: time, introduce: introduce, order: index)
        context.insert(learner)
    }
    try? context.save()
}
