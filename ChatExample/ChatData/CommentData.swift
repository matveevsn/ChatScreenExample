
import Foundation

struct CommentData: Codable {

    enum SendingStatus: Int, Codable {
        case progress
        case error
    }

    let sid: String?
    let uuid: String?
    let body: String?
    let publishedAt: Double?
    let rating: Int?

    var like: Int?
    var angry: Int?
    var dislike: Int?
    var sad: Int?
    var wow: Int?
    var haha: Int?
    var own: Int?

    let user: UserData?

    let isCommentingOpen: Bool

    let parentBody: String?
    let parentUser: UserData?
    let parentSid: String?

    var sendingStatus: SendingStatus?
    var localPublishedAt: Double?

    init(uuid: String, body: String, localPublishedAt: Double, user: UserData, sendingStatus: SendingStatus, parentSid: String?, parentBody: String? = nil, parentUser: UserData? = nil) {
        self.uuid = uuid
        self.body = body
        self.localPublishedAt = localPublishedAt
        self.user = user
        self.sendingStatus = sendingStatus
        self.parentSid = parentSid
        self.parentBody = parentBody
        self.parentUser = parentUser

        sid = nil
        publishedAt = nil
        rating = nil
        like = nil
        angry = nil
        dislike = nil
        sad = nil
        wow = nil
        haha = nil
        own = nil
        isCommentingOpen = false
    }
}
