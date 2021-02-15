
import Foundation

protocol ChatCommentsListModel: ChatCommentsListEvents, ChatCommentsListUserInteraction {

    var selectedIndex: IndexPath? { get }

    var onStartRefresh: (() -> Void)? { get set }
    var onStopRefresh: (() -> Void)? { get set }

    func loadTitle(completion: @escaping (String?) -> Void)

    func typedMessage() -> String?
    func setTypedMessage(message: String?)

    func loadComments(completion: @escaping ([ChatItem]?, [IndexPath]?, IndexPath?, ((IndexPath) -> IndexPath?)?, Bool) -> Void )
}

class ChatCommentsListModelImpl: ChatCommentsListModel {

    struct DataIndex {
        var index = [IndexPath: IndexPath]()
        var reverseIndex = [IndexPath: IndexPath]()
        var unreadedIndex: IndexPath?
        var maxCellIndex: IndexPath?
        var unreadedList: [IndexPath]?
        var lastReadedTimeStamp: Double?
    }

    let articleUid: String
    var data: [CommentData]? = [CommentData]()
    var dataComment: CommentData?
    var dataIndex: DataIndex? = DataIndex()
    var selectedUid: String?
    var uidToFlash: String?
    var isUserBanned: Bool

    private var articleTitle: String?
    var isCommentingOpen: Bool?
    private var comletionClosuresList = [() -> Void]()
    private var isArticleLoading: Bool

    init(articleUid: String, articleTitle: String? = nil, messageId: String? = nil) {
        self.articleUid = articleUid
        self.articleTitle = articleTitle
        self.uidToFlash = messageId
        self.isCommentingOpen = true
        self.isArticleLoading = false
        self.isUserBanned = false
    }

    var selectedIndex: IndexPath? {
        if let sourceIndex = self.data?.firstIndex(where: { ($0.sid != nil && $0.sid == selectedUid) || ($0.uuid != nil && $0.uuid == selectedUid) }) {
            return self.dataIndex?.index[IndexPath(row: sourceIndex, section: 0)]
        }
        return nil
    }

    var onStartRefresh: (() -> Void)?
    var onStopRefresh: (() -> Void)?

    var onCommentChanged: ((IndexPath, ChatItem) -> Void)?
    var onCommentInserted: ((IndexPath, ChatItem, [IndexPath]?, Bool) -> Void)?
    var onCommentDeleted: ((IndexPath, [IndexPath]?) -> Void)?
    var onCommentMoved: ((IndexPath, IndexPath) -> Void)?

    func loadTitle(completion: @escaping (String?) -> Void) {
        if articleTitle != nil {
            completion(articleTitle)
        }
    }

    func typedMessage() -> String? {
        return UnsendedCommentsManager.sharedInstance.getTypedMessage(articleUid: articleUid)
    }

    func setTypedMessage(message: String?) {
        UnsendedCommentsManager.sharedInstance.setTypedMessage(articleUid: articleUid, typedMessage: message)
    }

    func loadComments(completion: @escaping ([ChatItem]?, [IndexPath]?, IndexPath?, ((IndexPath) -> IndexPath?)?, Bool) -> Void) {
        reloadData(lastReadedMessageTimestamp: nil, isCommentingOpen: self.isCommentingOpen, completion: { (itemList, unreadedIndexes, indexToScroll, transformBlock) in
            completion(itemList, unreadedIndexes, indexToScroll, transformBlock, false)
        })
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
