
import Foundation

private let kChatDataKey = "chatDataStore"

class ChatCommentsManager {

    private var kLastReadedMessageTimestampKey = "lastReadedMessageTimestamp"
    private var kComplainedCommentsKey = "complainedComments"
    private var kPinnedChatsKey = "pinnedChats"
    private var kHidedChatsKey = "hidedChats"
    private var kInfoAlertInChatsListKey = "infoAlertInChatsListKey"
    private var kInfoAlertInChatScreenKey = "infoAlertInChatScreenKey"

    private var unreadTimestamps = [String: String]()
    private var complainedComments = [String: Set<String>]()
    private var pinnedChats = [String: String]()
    private var hidedChats = Set<String>()
    private var infoAlertInChatsListAlreadyShown: Bool
    private var infoAlertInChatScreenAlreadyShown: Bool

    static let sharedInstance = ChatCommentsManager()
    private init() {
        if let data = UserDefaults.standard.dictionary(forKey: kLastReadedMessageTimestampKey) as?  [String: String] {
            unreadTimestamps = data
        }

        if let data = UserDefaults.standard.value(forKey: kComplainedCommentsKey) as? Data {
            do {
                let decodedObject = try JSONDecoder().decode([String: Set<String>].self, from: data)
                complainedComments = decodedObject
            } catch {
                print("Error info: \(error)")
            }
        }

        if let data = UserDefaults.standard.dictionary(forKey: kPinnedChatsKey) as?  [String: String] {
            pinnedChats = data
        }

        if let data = UserDefaults.standard.array(forKey: kHidedChatsKey) as? [String] {
            hidedChats = Set(data)
        }

        infoAlertInChatsListAlreadyShown = UserDefaults.standard.bool(forKey: kInfoAlertInChatsListKey)
        infoAlertInChatScreenAlreadyShown = UserDefaults.standard.bool(forKey: kInfoAlertInChatScreenKey)
    }

    func setLastReadedMessageTimestamp(timestamp: Double, article: String) {
        unreadTimestamps[article] = String(format: "%f", timestamp)
        UserDefaults.standard.set(unreadTimestamps, forKey: kLastReadedMessageTimestampKey)
    }

    func setComplainedComment(comment: String, article: String) {
        if var comments = complainedComments[article] {
            comments.insert(comment)
            complainedComments[article] = comments
        } else {
            complainedComments[article] = Set([comment])
        }

        do {
            let encodedData = try JSONEncoder().encode(complainedComments)
            UserDefaults.standard.set(encodedData, forKey: kComplainedCommentsKey)
        } catch {
            print("Error info: \(error)")
        }
    }

    func getComplainedComments(article: String) -> Set<String>? {
        return complainedComments[article]
    }

    func pinChat(chatUid: String) -> Double {
        let pinnedTime = Date().timeIntervalSince1970
        pinnedChats[chatUid] = String(format: "%f", pinnedTime)
        UserDefaults.standard.set(pinnedChats, forKey: kPinnedChatsKey)
        return pinnedTime
    }

    func unpinChat(chatUid: String) {
        pinnedChats.removeValue(forKey: chatUid)
        UserDefaults.standard.set(pinnedChats, forKey: kPinnedChatsKey)
    }

    func gatAllPinnedChats() -> [String: String] {
        return pinnedChats
    }

    func hideChat(chatUid: String) {
        hidedChats.insert(chatUid)
        UserDefaults.standard.set(Array(hidedChats), forKey: kHidedChatsKey)
    }

    func getAllHiddenChats() -> Set<String> {
        return hidedChats
    }

    func shouldShowInfoAlertInChatList() -> Bool {
        return !infoAlertInChatsListAlreadyShown
    }

    func setInfoAlertInChatListShown() {
        infoAlertInChatsListAlreadyShown = true
        UserDefaults.standard.set(infoAlertInChatsListAlreadyShown, forKey: kInfoAlertInChatsListKey)
    }

    func shouldShowInfoAlertInChatScreen() -> Bool {
        return !infoAlertInChatScreenAlreadyShown
    }

    func setInfoAlertInChatScreenShown() {
        infoAlertInChatScreenAlreadyShown = true
        UserDefaults.standard.set(infoAlertInChatScreenAlreadyShown, forKey: kInfoAlertInChatScreenKey)
    }
}
