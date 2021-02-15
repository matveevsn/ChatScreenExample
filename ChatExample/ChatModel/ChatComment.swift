
import Foundation

enum VerticalPosition: Int {
    case single = 0
    case top
    case middle
    case bottom
}

enum HorizontalPosition: Int {
    case left = 0
    case right
}

enum CommentColorScheme: Int {
    case white = 0
    case blue
    case gray
}

enum SendingStatus: Int {
    case progress
    case error

    init?(status: Int) {
        switch status {
        case 0: self = .progress
        case 1: self = .error
        default: return nil
        }
    }
}

struct ChatComment: ChatItem {
    let body: String
    let publishedAt: String?
    var user: CommentUser?
    let emoutions: EmotionsModel?
    var verticalPosition: VerticalPosition = .single
    var horizontalPosition: HorizontalPosition = .left
    var colorScheme: CommentColorScheme = .white
    var sendingStatus: SendingStatus?
    var quote: ChatCommentQuote?
    var type: ChatItemType = .comment
    var isCommentingOpen: Bool

    init?(comment: CommentData?, isCommentingOpen: Bool) {
        guard let commentData = comment else { return nil }
        body = commentData.body?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) ?? ""
        publishedAt = commentData.publishedAt != nil ? stringFromDate(Date.init(timeIntervalSince1970: commentData.publishedAt!)) : nil

        user = CommentUser(user: commentData.user ?? UserData(sid: "", nickName: ""))
        emoutions = EmotionsModel(like: commentData.like, angry: commentData.angry, dislike: commentData.dislike, sad: commentData.sad, wow: commentData.wow, haha: commentData.haha)

        quote = ChatCommentQuote(parentBody: commentData.parentBody, parentUser: commentData.parentUser, type: .inOtherMessage)

        if let status = commentData.sendingStatus {
            sendingStatus = SendingStatus(status: status.rawValue)
        }
        self.isCommentingOpen = isCommentingOpen
    }
}

private func stringFromDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm"
    return formatter.string(from: date)
}
