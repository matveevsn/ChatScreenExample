
import Foundation

struct ChatUread: ChatItem {
    var type: ChatItemType = .unread
    var title: String?

    init(title: String) {
        self.title = title
    }
}
