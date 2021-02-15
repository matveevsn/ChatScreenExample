
import Foundation

extension ArticleChatController {

    func initializeModelListHandlers() {

        commentsList?.onCommentInserted = { [weak self] (index, comment, unreadedList, scrollToBottom) in
            self?.chatListView.insertItem(item: comment, indexPath: index, unreadedList: unreadedList, scrollToBottom: scrollToBottom)
            self?.unreadView.setupView(unreadedCount: unreadedList?.count ?? 0, animated: true)
        }

        commentsList?.onCommentMoved = { [weak self] (indexFrom, indexTo) in
            self?.chatListView.moveItem(fromPath: indexFrom, toPath: indexTo)
        }

        commentsList?.onCommentChanged = { [weak self] (index, comment) in
            self?.chatListView.updateItem(item: comment, indexPath: index)
        }

        commentsList?.onCommentDeleted = { [weak self] (index, unreadedList) in
            self?.chatListView.deleteItem(indexPath: index, unreadedList: unreadedList)
            self?.unreadView.setupView(unreadedCount: unreadedList?.count ?? 0, animated: true)
        }

        commentsList?.onStartRefresh = { [weak self] in
            self?.navView.showActivityView(state: .refreshing)
        }

        commentsList?.onStopRefresh = { [weak self] in
            self?.navView.hideActivityView()
        }
    }

    func updateModelList() {

        commentsList?.loadTitle(completion: { [weak self] (title) in
            self?.navView.title.text = title
        })

        commentsList?.loadComments(completion: { [weak self] (comments, _, _, _, _) in
            if let list = comments {
                self?.chatListView.layoutIfNeeded()
                self?.chatListView.reloadView(comments: list, indexToScroll: nil)
            }
        })
    }

}
