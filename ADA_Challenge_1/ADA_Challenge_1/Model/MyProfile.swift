import Foundation
import SwiftData

@Model
class MyProfile {
    var nickname: String
    var time: String
    var introduce: String
    @Attribute(.externalStorage) var imageData: Data?

    init(nickname: String, time: String, introduce: String, imageData: Data?) {
        self.nickname = nickname
        self.time = time
        self.introduce = introduce
        self.imageData = imageData
    }
}
