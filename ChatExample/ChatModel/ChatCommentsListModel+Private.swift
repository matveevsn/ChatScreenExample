
import Foundation

extension ChatCommentsListModelImpl {

    func insertCommentIfNeed(commentData: CommentData, userId: String?) {
        if let uuid = commentData.uuid {
            if let firstIndex = self.data?.firstIndex(where: {$0.uuid == uuid}) {
                self.data?[firstIndex] = commentData
                if let chatComment = buildComment(at: firstIndex, buildParams: BuildParams(
                        userId: userId,
                        complainedCommentsUids: ChatCommentsManager.sharedInstance.getComplainedComments(article: articleUid),
                        isCommentingOpen: self.isCommentingOpen
                    )), let updatedCellIndex = self.dataIndex?.index[IndexPath(row: firstIndex, section: 0)] {
                        self.onCommentChanged?(updatedCellIndex, chatComment)
                        return
                }
            }
        }
        insertComment(commentData: commentData, userId: userId)
    }

    func insertComment(commentData: CommentData, userId: String?) {
        if self.data != nil && self.data?.firstIndex(where: { (commentData.sid != nil && $0.sid == commentData.sid) || (commentData.uuid != nil && $0.uuid == commentData.uuid)}) == nil {

            let cellIndexPath = insertDataWithIndexRebuild(commentData: commentData)

            if let chatComment = buildComment(at: self.data!.count - 1, buildParams: BuildParams(
                userId: userId,
                complainedCommentsUids: ChatCommentsManager.sharedInstance.getComplainedComments(article: articleUid),
                isCommentingOpen: self.isCommentingOpen
                )) {
                    self.onCommentInserted?(cellIndexPath, chatComment, self.dataIndex?.unreadedList, userId == commentData.user?.sid)
                    if let previousChatComment = buildComment(at: self.data!.count - 2, buildParams: BuildParams(
                        userId: userId,
                        complainedCommentsUids: ChatCommentsManager.sharedInstance.getComplainedComments(article: articleUid),
                        isCommentingOpen: self.isCommentingOpen
                        )) {
                            let previousCommentSourceIndex = IndexPath(row: self.data!.count - 2, section: 0)
                            if let previousCommentCellIndex = self.dataIndex?.index[previousCommentSourceIndex] {
                                self.onCommentChanged?(previousCommentCellIndex, previousChatComment)
                            }
                    }
            }
        } else {
            assert(false)
        }
    }

    func deleteComment(sid: String, userId: String?) {
        assert(Thread.isMainThread)
        if let commentIndex = self.data?.firstIndex(where: {$0.sid == sid || $0.uuid == sid}) {
            let commentPath = IndexPath(row: commentIndex, section: 0)
            if let cellIndexPath = self.dataIndex?.index[commentPath] {

                self.removeDataWithIndexRebuild(commentPath: commentPath)
                self.onCommentDeleted?(cellIndexPath, self.dataIndex?.unreadedList)

                let previousSourceIndex = IndexPath(row: commentPath.row - 1, section: 0)
                if let previousComment = buildComment(at: previousSourceIndex.row, buildParams: BuildParams(
                    userId: userId,
                    complainedCommentsUids: ChatCommentsManager.sharedInstance.getComplainedComments(article: articleUid),
                    isCommentingOpen: self.isCommentingOpen
                    )), let previosCellIndex = self.dataIndex?.index[previousSourceIndex] {
                        self.onCommentChanged?(previosCellIndex, previousComment)
                }

                if let nextComment = buildComment(at: commentPath.row, buildParams: BuildParams(
                    userId: userId,
                    complainedCommentsUids: ChatCommentsManager.sharedInstance.getComplainedComments(article: articleUid),
                    isCommentingOpen: self.isCommentingOpen
                    )), let nextCellIndex = self.dataIndex?.index[commentPath] {
                        self.onCommentChanged?(nextCellIndex, nextComment)
                }
            }
        }
    }

    func removeDataWithIndexRebuild(commentPath: IndexPath) {
        self.data?.remove(at: commentPath.row)
        self.removeDataIndex(indexPath: commentPath)
    }

    func insertDataWithIndexRebuild(commentData: CommentData) -> IndexPath {
        let sourceIndexPath = IndexPath(row: self.data!.count, section: 0)
        let cellIndexPath = IndexPath(row: self.dataIndex?.maxCellIndex?.row != nil ? self.dataIndex!.maxCellIndex!.row + 1 : 0, section: 0)

        self.data!.append(commentData)

        self.dataIndex?.reverseIndex[cellIndexPath] = sourceIndexPath
        self.dataIndex?.index[sourceIndexPath] = cellIndexPath
        self.dataIndex?.maxCellIndex = cellIndexPath
        self.dataIndex?.unreadedList?.append(cellIndexPath)

        return cellIndexPath
    }

    private func removeDataIndex(indexPath: IndexPath) {
        if dataIndex?.index[indexPath] != nil {

            var correctedIndex = [IndexPath: IndexPath]()
            var reverseCorrectedIndex = [IndexPath: IndexPath]()
            var cellIndexTransformMap = [IndexPath: IndexPath]()

            dataIndex?.index.forEach({ (key: IndexPath, value: IndexPath) in
                if key != indexPath {
                    let keyPath = key.row > indexPath.row ? IndexPath(row: key.row - 1, section: 0) : key
                    let valuePath = key.row > indexPath.row ? IndexPath(row: value.row - 1, section: 0) : value
                    correctedIndex[keyPath] = valuePath
                    reverseCorrectedIndex[valuePath] = keyPath
                    cellIndexTransformMap[value] = valuePath
                }
            })

            var transformedUnreadedCellIndexes = [IndexPath]()
            dataIndex?.unreadedList?.forEach({ (unreadedIndex) in
                if let index = cellIndexTransformMap[unreadedIndex] {
                    transformedUnreadedCellIndexes.append(index)
                } else {
                    if dataIndex?.index[indexPath] != unreadedIndex {
                        assert(false)
                    }
                }
            })

            dataIndex?.index = correctedIndex
            dataIndex?.reverseIndex = reverseCorrectedIndex
            dataIndex?.unreadedList = transformedUnreadedCellIndexes
            if let maxRow = self.dataIndex?.maxCellIndex?.row {
                dataIndex?.maxCellIndex = maxRow > 0 ? IndexPath(row: maxRow - 1, section: 0) : nil
            }
        }
    }

    func reloadData(lastReadedMessageTimestamp: Double?, isCommentingOpen: Bool?, completion: @escaping ([ChatItem], [IndexPath]?, IndexPath?, ((IndexPath) -> IndexPath?)?) -> Void) {
        assert(Thread.isMainThread)
        completion([ChatItem](), nil, nil, nil)
    }

    private func indexForFlash() -> IndexPath? {
        if let messageId = self.uidToFlash,
            let messageSourceIndex = self.data?.firstIndex(where: {$0.sid == messageId}),
            let newCellIndex = self.dataIndex?.index[IndexPath(row: messageSourceIndex, section: 0)] {
            return newCellIndex
        }
        return nil
    }

    func selectedData() -> CommentData? {
        guard let uid = selectedUid else { return nil }
        if let index = self.data?.firstIndex(where: { $0.sid == uid || $0.uuid == uid }) {
            return self.data?[index]
        }
        if dataComment?.sid == uid {
            return dataComment
        }
        return nil
    }

}
