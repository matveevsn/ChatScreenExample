
import Foundation

extension ArticleChatController: SendViewDelegate {
    func shouldIncreaseInputFieldHeight() -> Bool {
        return chatListView.frame.height > kMinimumHeight
    }

    func onCloseQuote() {
        commentsList?.clearSelection()
        sendView.clear()
    }

    func onSend(message: String) {
        sendView.clear()

        sendView.layoutIfNeeded()
        chatListView.layoutIfNeeded()

        self.commentsList?.sendComment(message: message, repliedIndex: self.commentsList?.selectedIndex)
        self.commentsList?.clearSelection()
    }
}
