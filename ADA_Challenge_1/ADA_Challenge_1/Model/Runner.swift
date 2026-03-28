import Foundation

struct Runner: Identifiable {
    let id = UUID()
    let name: String
    let imageName: String? // nil이면 애플 로고
    let time: String
    let introduce: String
}

let imageNames = ["Jiwoo", "Carmen", "Yuha", "Stella",
                  "Juun", "Ana", "Ian", "Yeon"]

let mockRunners = (0..<180).map { index in
    let name = index < 8 ? imageNames[index % 8] : "Runner \(index)"
    let imageName = index < 8 ? imageNames[index % 8] : nil
    let time = index % 2 == 0 ? "오전" : "오후"
    let introduce = "안녕하세요 \(name) 입니다 :)"
    
    return Runner(
        name: name,
        imageName: imageName,
        time: time,
        introduce: introduce
    )
}

