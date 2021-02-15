
import Foundation

enum ChatCommentActionType: Int {
    case reply = 0
    case remove
    case complain
    case resend
}

struct ChatCommentAction {
    let title: String
    let type: ChatCommentActionType
}
