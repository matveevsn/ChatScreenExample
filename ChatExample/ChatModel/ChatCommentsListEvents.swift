
import Foundation

protocol ChatCommentsListEvents {
    var onCommentChanged: ((IndexPath, ChatItem) -> Void)? { get set }
    var onCommentInserted: ((IndexPath, ChatItem, [IndexPath]?, Bool) -> Void)? { get set }
    var onCommentDeleted: ((IndexPath, [IndexPath]?) -> Void)? { get set }
    var onCommentMoved: ((IndexPath, IndexPath) -> Void)? { get set }
}
