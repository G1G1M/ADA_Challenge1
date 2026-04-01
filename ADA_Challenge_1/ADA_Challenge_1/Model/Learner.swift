import Foundation

struct Learner: Identifiable, Codable, Equatable { // Codable: 기기끼리 데이터를 주고받을 때, Swift 구조체를 그대로 전송할 수 없기 때문, Equatable: 이전 값과 새로운 값을 비교하기 위해 사용
    var id = UUID() // 고정된 값이 아닌 디코딩할 때 값을 넣기 위해 var로 변경
    let name: String
    let imageName: String? // nil이면 애플 로고
    let time: String
    let introduce: String
}

let imageNames = ["Jiwoo", "Carmen", "Yuha", "Stella",
                  "Juun", "Ana", "Ian", "Yeon"]

let mockLearners = (0..<180).map { index in // 서버 없이 사용할 임시 데이터, map: 각 요소를 변환해서 새 배열로 반환하는 함수
    let name = index < 8 ? imageNames[index % 8] : "Learner \(index)"
    let imageName: String? = nil
    let time = index % 2 == 0 ? "오전" : "오후"
    let introduce = "안녕하세요 \(name) 입니다 :)"
    
    return Learner(
        name: name,
        imageName: imageName,
        time: time,
        introduce: introduce
    )
}
