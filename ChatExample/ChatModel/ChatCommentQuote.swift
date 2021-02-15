
import Foundation

enum ChatCommentQuoteType: Int {
    case inMyMessage
    case inOtherMessage
    case inSendField
}

struct ChatCommentQuote {
    var parentBody: String?
    var parentUser: CommentUser?
    var type: ChatCommentQuoteType

    init(parentBody: String?, parentUser: UserData?, type: ChatCommentQuoteType) {
        self.parentBody = parentBody?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if let user = parentUser {
            self.parentUser = CommentUser(user: user)
        } else {
            self.parentUser = nil
        }
        self.type = type
    }
}
