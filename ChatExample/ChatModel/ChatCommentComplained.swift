
import Foundation

struct ChatCommentComplained: ChatItem {
    var body: String
    var user: CommentUser?
    var verticalPosition: VerticalPosition = .single
    var type: ChatItemType = .complained
    var colorScheme: CommentColorScheme = .gray

    init?(comment: CommentData?) {
        guard let commentData = comment else { return nil }
        body = commentData.body!
        user = CommentUser(user: commentData.user ?? UserData(sid: "", nickName: ""))
    }
}
