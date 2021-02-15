
import Foundation
import UIKit

extension ArticleChatController: ArticleChatInteractive {
    func onRate(indexPath: IndexPath, point: CGPoint) {
    }

    func onScroll(isScrollOnTop: Bool) {
        if isScrollOnTop {
            navView.hideSeparator()
        } else {
            navView.showSeparator()
        }
    }

    func shouldUpdatePosition() -> Bool {
        return commentsList?.selectedIndex == nil
    }

    func onScroll(redLine: Bool, unreadedIndexes: [IndexPath]?) {
        if !redLine {
            unreadView.show()
        } else {
            unreadView.hide()
            unreadView.setupView(unreadedCount: 0, animated: false)
        }

        if let unreaded = unreadedIndexes {
            if let updatedUreadedIndexes = commentsList?.showIndexes(indexes: unreaded) {
                unreadView.setupView(unreadedCount: updatedUreadedIndexes.count, animated: true)
                chatListView.updateUnreadedOrigins(unreadedIndexList: updatedUreadedIndexes)
            }
        }
    }

    func onCommentMessageLongTap(indexPath: IndexPath) {

        if sendView.dismissKeyboardIfNeed() {
            return
        }

        let actions = commentsList?.selectItem(indexPath: indexPath)
        if actions?.count ?? 0 == 0 { return }

        let actionController = CustomActionSheetViewController()

        actions?.forEach({ (action) in
            if action.type == .reply {
                addReplyAction(actionController: actionController, title: action.title)
            } else if action.type == .remove {
                addRemoveAction(actionController: actionController, title: action.title)
            } else {
                actionController.addRegularAction(title: action.title, handler: nil)
            }
        })

        actionController.addCancelAction(title: NSLocalizedString("article_chat_complain_action_cancel", comment: ""), handler: { [weak self, weak actionController] in
            actionController?.dismiss(animated: true, completion: nil)
            if let indexPath = self?.commentsList?.selectedIndex {
                self?.hideShadowView(indexPath: indexPath, completion: nil)
                self?.commentsList?.clearSelection()
            }
        })

        actionController.viewWillTransition = { [weak self, weak actionController] in
            actionController?.dismiss(animated: true, completion: nil)
            if let indexPath = self?.commentsList?.selectedIndex {
                self?.hideShadowView(indexPath: indexPath, completion: nil)
            }
        }

        actionController.onClose = {
            if let indexPath = self.commentsList?.selectedIndex {
                self.hideShadowView(indexPath: indexPath, completion: nil)
            }
        }

        actionController.onActionSheetWillAppearWithHeight = { (height) in
            self.showShadowView(indexPath: indexPath, actionSheetHeight: height)
        }

        actionController.modalPresentationStyle = .overFullScreen
        self.present(actionController, animated: true, completion: nil)
    }

    func onCommentMessageQuoteTap(indexPath: IndexPath) {
        if let parentIndex = commentsList?.parentComment(indexPath: indexPath) {
            chatListView.scrollToWithFlash(indexPath: parentIndex, animated: true)
        }
    }

    func onSwipe(indexPath: IndexPath) {
        if let quote = self.commentsList?.quote(indexPath: indexPath) {
            _ = commentsList?.selectItem(indexPath: indexPath)
            self.updateSendView(quote: quote)
        }
    }

    func isSwipeEnabled() -> Bool {
        return !isEditControlsBlocked()
    }

    private func addReplyAction(actionController: CustomActionSheetViewController, title: String) {
        actionController.addRegularAction(title: title, handler: { [weak self, weak actionController] in
            if let selectedIndex = self?.commentsList?.selectedIndex {
                if let quote = self?.commentsList?.quote(indexPath: selectedIndex) {
                    print("Find quote: \(String(describing: quote))")
                    actionController?.dismiss(animated: true, completion: { [weak self] in
                        self?.updateSendView(quote: quote)
                    })
                    self?.hideShadowView(indexPath: selectedIndex, completion: nil)
                }
            }
        })
    }

    private func addRemoveAction(actionController: CustomActionSheetViewController, title: String) {
        actionController.addRegularAction(title: title, handler: { [weak self, weak actionController] in
            actionController?.dismiss(animated: true, completion: { [weak self] in
                if let selectedIndex = self?.commentsList?.selectedIndex {
                    self?.commentsList?.deleteComment(indexPath: selectedIndex, completion: { (success) in
                        print("Delete result: \(success)")
                    })
                }
            })
            if let selectedIndex = self?.commentsList?.selectedIndex {
                self?.hideShadowView(indexPath: selectedIndex, completion: nil)
            }
        })
    }

    private func updateSendView(quote: ChatCommentQuote) {
        sendView.setup(quote: quote)
        sendView.showKeyboard()
    }

    private func isEditControlsBlocked() -> Bool {
        return false
    }

}

extension ArticleChatController: ChatNavInteractive {

    func onNavTitleTap() {

        if shouldCloseOnArticleOpen {
            onBack()
            return
        }
    }
}
