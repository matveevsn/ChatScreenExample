
import Foundation

class UnsendedCommentsManager {

    struct UnsendedMessage: Codable {
        let articleUid: String
        var comment: CommentData
    }

    private var kTypedMessagesKey = "typedMessagesKey"
    private var typedMessages = [String: String]()

    static let sharedInstance = UnsendedCommentsManager()

    private init() {
        loadTypedMessages()
    }

    private func loadTypedMessages() {
        if let storedMessages = UserDefaults.standard.object(forKey: kTypedMessagesKey) as? [String: String] {
            typedMessages = storedMessages
        }
    }

    private func saveTypedMessages() {
        UserDefaults.standard.set(typedMessages, forKey: kTypedMessagesKey)
        UserDefaults.standard.synchronize()
    }

    func enqueueMessage(articleUid: String, message: String, user: UserData, parentSid: String?, parentBody: String?, parentUser: UserData?) -> CommentData {
        return CommentData(
            uuid: NSUUID().uuidString,
            body: message,
            localPublishedAt: Date().timeIntervalSince1970,
            user: user,
            sendingStatus: .progress,
            parentSid: parentSid,
            parentBody: parentBody,
            parentUser: parentUser
        )
    }

    public func setTypedMessage(articleUid: String, typedMessage: String?) {
        if let message = typedMessage {
            typedMessages[articleUid] = message
        } else {
            typedMessages.removeValue(forKey: articleUid)
        }
        saveTypedMessages()
    }

    public func getTypedMessage(articleUid: String) -> String? {
        return typedMessages[articleUid]
    }
}
