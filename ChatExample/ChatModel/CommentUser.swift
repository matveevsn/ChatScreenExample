
import Foundation

struct CommentUser {
    let nickName: String
    let avatar: String?

    init(user: UserData) {
        nickName = user.nickName
        avatar = user.avatar
    }
}
