
import Foundation

extension ChatCommentsListModelImpl {

    struct BuildParams {
        var userId: String?
        var complainedCommentsUids: Set<String>?
        var isCommentingOpen: Bool?

        init(userId: String? = nil, complainedCommentsUids: Set<String>? = nil, isCommentingOpen: Bool?) {
            self.userId = userId
            self.complainedCommentsUids = complainedCommentsUids
            self.isCommentingOpen = isCommentingOpen
        }
    }

    func buildComment(previousComment: CommentData?, buildComment: CommentData?, nextComment: CommentData?, buildParams: BuildParams?) -> ChatItem? {
        guard let currentComment = buildComment else { return nil }

        let prevUserSid = previousComment?.user?.sid
        let currentUserSid = currentComment.user?.sid
        let nextUserSid = nextComment?.user?.sid

        if let sid = currentComment.sid,
            buildParams?.complainedCommentsUids?.contains(sid) ?? false {
            var commentComplained = ChatCommentComplained( comment: currentComment )

            commentComplained?.body = NSLocalizedString("article_chat_complain_message_text", comment: "")

            commentComplained?.verticalPosition = verticalPosition(
                prevUserSid: prevUserSid,
                currentUserSid: currentUserSid,
                nextUserSid: nextUserSid
            )

            if prevUserSid == currentUserSid || currentUserSid == buildParams?.userId {
                commentComplained?.user = nil
            }

            return commentComplained
        } else {
            var comment = ChatComment( comment: currentComment, isCommentingOpen: buildParams?.isCommentingOpen ?? false )

            comment?.verticalPosition = verticalPosition(
                prevUserSid: prevUserSid,
                currentUserSid: currentUserSid,
                nextUserSid: nextUserSid
            )

            if prevUserSid == currentUserSid {
                comment?.user = nil
            }

            if currentUserSid == buildParams?.userId {
                comment?.user = nil
                comment?.colorScheme = .blue
                comment?.quote?.type = .inMyMessage
                comment?.horizontalPosition = .right
            }

            return comment
        }
    }

    func buildComment(at index: Int, buildParams: BuildParams?) -> ChatItem? {
        if index >= 0 && index < self.data?.count ?? 0 {
            let previousCommentData = index - 1 >= 0 ? self.data![index - 1] : nil
            let currentCommentData = self.data![index]
            let nextCommentData = index + 1 < self.data!.count ? self.data![index + 1] : nil
            return buildComment(previousComment: previousCommentData, buildComment: currentCommentData, nextComment: nextCommentData, buildParams: buildParams)
        }
        return nil
    }

    func buildCommentsList(commentsData: [CommentData], lastReadedMessageTimestamp: Double?, buildParams: BuildParams?) -> ([ChatItem], DataIndex) {

        var result = [ChatItem]()
        var dataIndex = DataIndex()
        var unreadedList = [IndexPath]()
        for index in 0..<commentsData.count {

            let comment = buildComment(
                previousComment: index > 0 ? commentsData[index - 1] : nil,
                buildComment: commentsData[index],
                nextComment: index < commentsData.count - 1 ? commentsData[index + 1] : nil,
                buildParams: buildParams
            )

            if let timestamp = lastReadedMessageTimestamp,
                let published = commentsData[index].publishedAt,
                published > timestamp,
                dataIndex.unreadedIndex == nil,
                commentsData[index].user?.sid != buildParams?.userId {
                    dataIndex.unreadedIndex = IndexPath(row: result.count, section: 0)
                    result.append(ChatUread(title: NSLocalizedString("article_chat_unread_separator_title", comment: "")))
            }

            dataIndex.index[IndexPath(row: index, section: 0)] = IndexPath(row: result.count, section: 0)
            dataIndex.reverseIndex[IndexPath(row: result.count, section: 0)] = IndexPath(row: index, section: 0)

            if dataIndex.unreadedIndex != nil && commentsData[index].user?.sid != buildParams?.userId {
                unreadedList.append(IndexPath(row: result.count, section: 0))
            }

            result.append(comment!)

        }

        if dataIndex.unreadedIndex == nil && result.count > 0 {
            dataIndex.unreadedIndex = IndexPath(row: result.count - 1, section: 0)
        }

        dataIndex.unreadedList = unreadedList
        dataIndex.maxCellIndex = result.count > 0 ? IndexPath(row: result.count - 1, section: 0) : nil

        return (result, dataIndex)
    }

    private func verticalPosition(prevUserSid: String?, currentUserSid: String?, nextUserSid: String?) -> VerticalPosition {
        if prevUserSid != currentUserSid {
            if currentUserSid != nextUserSid {
                return .single
            } else {
                return .top
            }
        } else {
            if currentUserSid != nextUserSid {
                return .bottom
            } else {
                return .middle
            }
        }
    }

}
