
import Foundation

enum ChatItemType: String, Hashable {
    case comment
    case unread
    case complained
}

protocol ChatItem {
    var type: ChatItemType { get }
}
