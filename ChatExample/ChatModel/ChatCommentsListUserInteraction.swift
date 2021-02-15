
import Foundation

protocol ChatCommentsListUserInteraction {

    func sendComment(message: String, repliedIndex: IndexPath?)
    func deleteComment(indexPath: IndexPath, completion: @escaping (Bool) -> Void)

    func selectItem(indexPath: IndexPath) -> [ChatCommentAction]
    func clearSelection()

    func quote(indexPath: IndexPath) -> ChatCommentQuote?
    func showIndexes(indexes: [IndexPath]) -> [IndexPath]?
    func parentComment(indexPath: IndexPath) -> IndexPath?
}

extension ChatCommentsListModelImpl: ChatCommentsListUserInteraction {

    func sendComment(message: String, repliedIndex: IndexPath?) {
        if  let userId = ProfileManager.shared.profile?.sid,
            let nickName = ProfileManager.shared.profile?.displayName
        {

            var repliedData: CommentData?
            if let indexPath = repliedIndex,
               let sourceIndexPath = dataIndex?.reverseIndex[indexPath],
               sourceIndexPath.row < self.data?.count ?? 0 {
                repliedData = self.data![sourceIndexPath.row]
            } else {
                repliedData = selectedData()
            }

            let comment = UnsendedCommentsManager.sharedInstance.enqueueMessage(
                articleUid: self.articleUid,
                message: message,
                user: UserData(sid: userId, nickName: nickName),
                parentSid: repliedData?.sid,
                parentBody: repliedData?.body,
                parentUser: repliedData?.user
            )
            insertComment(commentData: comment, userId: userId)
        }
    }

    func deleteComment(indexPath: IndexPath, completion: @escaping (Bool) -> Void) {
        if let sourceIndexPath = dataIndex?.reverseIndex[indexPath],
           sourceIndexPath.row < self.data?.count ?? 0 {
            let commentData = self.data![sourceIndexPath.row]
            if let uuid = commentData.uuid,
               commentData.sendingStatus == .progress || commentData.sendingStatus == .error {
                deleteComment(sid: uuid, userId: ProfileManager.shared.profile?.sid)
            }
        }
    }

    func selectItem(indexPath: IndexPath) -> [ChatCommentAction] {
        var actions = [ChatCommentAction]()
        if !(isCommentingOpen ?? false) { return actions }
        if let sourceIndexPath = dataIndex?.reverseIndex[indexPath] {
            assert(sourceIndexPath.section == 0 && sourceIndexPath.row < self.data?.count ?? 0)
            if sourceIndexPath.row < self.data?.count ?? 0 {
                if let status = self.data![sourceIndexPath.row].sendingStatus {
                    if status == .error {
                        actions.append(ChatCommentAction(title: NSLocalizedString("article_chat_resend_action_name", comment: ""), type: .resend))
                    }
                } else {
                    actions.append(ChatCommentAction(title: NSLocalizedString("article_chat_reply_action_name", comment: ""), type: .reply))
                }
                if self.data![sourceIndexPath.row].user?.sid == ProfileManager.shared.profile?.sid {
                    actions.append(ChatCommentAction(title: NSLocalizedString("article_chat_remove_action_name", comment: ""), type: .remove))
                } else {
                    actions.append(ChatCommentAction(title: NSLocalizedString("article_chat_complain_action_name", comment: ""), type: .complain))
                }
                selectedUid = self.data![sourceIndexPath.row].sid != nil ? self.data![sourceIndexPath.row].sid : self.data![sourceIndexPath.row].uuid
            }
        } else {
            assert(false)
        }
        return actions
    }

    func clearSelection() {
        self.selectedUid = nil
    }

    func quote(indexPath: IndexPath) -> ChatCommentQuote? {
        if let sourceIndexPath = dataIndex?.reverseIndex[indexPath] {
            assert(sourceIndexPath.section == 0 && sourceIndexPath.row < self.data?.count ?? 0)
            if let comment = data?[sourceIndexPath.row] {
                return ChatCommentQuote(parentBody: comment.body, parentUser: comment.user, type: .inSendField)
            }
        } else {
            assert(false)
        }
        return nil
    }

    func showIndexes(indexes: [IndexPath]) -> [IndexPath]? {

        indexes.forEach { (index) in
            if let indexToRemove = self.dataIndex?.unreadedList?.firstIndex(of: index) {
                self.dataIndex?.unreadedList?.removeFirst(indexToRemove + 1)
            }
        }

        return self.dataIndex?.unreadedList
    }

    func parentComment(indexPath: IndexPath) -> IndexPath? {
        if let sourceIndexPath = dataIndex?.reverseIndex[indexPath] {
            assert(sourceIndexPath.section == 0 && sourceIndexPath.row < self.data?.count ?? 0)
            if let parentSid = data?[sourceIndexPath.row].parentSid {
                if let firstIndex = self.data?.firstIndex(where: {$0.sid == parentSid}) {
                    return dataIndex?.index[IndexPath(row: firstIndex, section: 0)]
                }
            }
        } else {
            assert(false)
        }
        return nil
    }
}
