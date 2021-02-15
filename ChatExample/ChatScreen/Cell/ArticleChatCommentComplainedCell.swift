
import Foundation
import UIKit

private let commentHorizontalPadding: CGFloat = 8
private let commentVerticalPadding: CGFloat = 5
private let commentCornerRadiusSize = CGSize(width: 15, height: 15)
private let rateButtonSize = CGSize(width: 34, height: 34)
private let rateButtonMargin: CGFloat = 8
private let spaceBetweenCommentAndRateButton: CGFloat = 8
private let avatarBottomMargin: CGFloat = 8
private let longPressAnmationDuration = 0.2

class ArticleChatCommentComplainedCell: UITableViewCell {

    private (set) var model: ChatCommentComplained!

    private (set) var messageView: ArticleChatMessageView = {
        let messageView = ArticleChatMessageView()
        messageView.isUserInteractionEnabled = true
        return messageView
    }()

    private (set) var avatarView: ArticleChatAvatarView = {
        let avatarView = ArticleChatAvatarView()
        return avatarView
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        self.contentView.backgroundColor = UIColor.color(for: .otherBackground)
        self.contentView.addSubview(messageView)
        self.contentView.addSubview(avatarView)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        avatarView.frame = CGRect(
            x: commentHorizontalPadding,
            y: commentVerticalPadding,
            width: self.contentView.bounds.size.width - 2*commentHorizontalPadding,
            height: ArticleChatAvatarView.calculateCellHeight(user: model.user, width: self.contentView.bounds.size.width - 2*commentHorizontalPadding)
        )

        let messageViewYPos = avatarView.frame.size.height > 0 ? avatarView.frame.maxY + avatarBottomMargin : commentVerticalPadding
        let messageViewWidth = self.contentView.bounds.width
                                - rateButtonMargin
                                - rateButtonSize.width
                                - spaceBetweenCommentAndRateButton
                                - commentHorizontalPadding

        messageView.frame = CGRect(
               x: commentHorizontalPadding,
               y: messageViewYPos,
               width: messageViewWidth,
               height: ArticleChatMessageView.calculateHeight(
                    message: model.body,
                    date: nil,
                    quote: nil,
                    sendingStatus: nil,
                    width: messageViewWidth
               )
        )

        messageView.roundedRect(messageView.bounds, byRoundingCorners: cornerRadius(), cornerRadius: commentCornerRadiusSize)
    }

    func cornerRadius() -> UIRectCorner {
        if model.verticalPosition == .single {
            return [.bottomLeft, .bottomRight, .topRight]
        } else if model.verticalPosition == .top {
            return [.topRight]
        } else if model.verticalPosition == .middle {
            return []
        } else if model.verticalPosition == .bottom {
            return [.bottomLeft, .bottomRight]
        }

        return .allCorners
    }

    class func calculateMessageWidth(width: CGFloat) -> CGFloat {
        return width - rateButtonMargin - rateButtonSize.width - spaceBetweenCommentAndRateButton - commentHorizontalPadding
    }

    class func getCommentVerticalPadding() -> CGFloat {
        return commentVerticalPadding
    }

    class func getAvatarBottomMargin() -> CGFloat {
        return avatarBottomMargin
    }
}

extension ArticleChatCommentComplainedCell: ArticleChatConfigurable {

    public func configure(chatItem: ChatItem, chatItemDelegate: ChatItemDelegate?) {
        guard let chatComment = chatItem as? ChatCommentComplained else { return }
        self.model = chatComment

        messageView.setup(
            body: model.body,
            publishedAt: nil,
            emotionsModel: nil,
            quote: nil,
            sendingStatus: nil,
            colorScheme: chatComment.colorScheme
        )

        avatarView.setup(user: model.user)
    }

    static func calculateCellHeight(chatItem: ChatItem, width: CGFloat) -> CGFloat {
        guard let model = chatItem as? ChatCommentComplained else { return 0 }
        let messageWidth = calculateMessageWidth(width: width)
        let avatarHeight = ArticleChatAvatarView.calculateCellHeight(user: model.user, width: messageWidth)
        let height = getCommentVerticalPadding()
                + avatarHeight
                + (avatarHeight > 0 ? getAvatarBottomMargin() : 0)
                + ArticleChatMessageView.calculateHeight(
                                                        message: model.body,
                                                        date: nil,
                                                        quote: nil,
                                                        sendingStatus: nil,
                                                        width: messageWidth
                                                    )
                + getCommentVerticalPadding()

        return round(height)
    }
}
