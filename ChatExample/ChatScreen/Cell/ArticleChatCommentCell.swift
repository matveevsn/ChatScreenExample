
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

protocol CommentDelegate: ChatItemDelegate {
    func onMessageLongPress(point: CGPoint)
    func onQuoteTap(point: CGPoint)
    func onRate(point: CGPoint)
}

protocol Swipeable {
    func likeButtonOrigin() -> CGPoint
}

class ArticleChatCommentCell: UITableViewCell, Skinable {

    private (set) var model: ChatComment!
    weak private var messageDelegate: CommentDelegate?

    private (set) var messageView: ArticleChatMessageView = {
        let messageView = ArticleChatMessageView()
        messageView.isUserInteractionEnabled = true
        return messageView
    }()

    private (set) var avatarView: ArticleChatAvatarView = {
        let avatarView = ArticleChatAvatarView()
        return avatarView
    }()

    private (set) var rateButton: UIButton = {
        let rateButton = UIButton(type: .custom)
        rateButton.setImage(UIImage.schemeImage(for: "rating"), for: .normal)
        return rateButton
    }()

    private (set) var errorIcoView: UIImageView = {
        let errorIco = UIImageView(image: UIImage(named: "sendError"))
        return errorIco
    }()

    private (set) var shadowView: UIView = {
        let shadowView = UIView()
        shadowView.backgroundColor = .black
        return shadowView
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
        self.contentView.addSubview(errorIcoView)
        self.contentView.addSubview(shadowView)
        self.contentView.addSubview(messageView)
        self.contentView.addSubview(avatarView)
        self.contentView.addSubview(rateButton)

        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(recognizer:)))
        longPressRecognizer.minimumPressDuration = 0.25
        messageView.addGestureRecognizer(longPressRecognizer)

        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:)))
        messageView.quoteView.addGestureRecognizer(tapRecognizer)

        rateButton.addTarget(self, action: #selector(onRate), for: .touchUpInside)

    }

    @objc func onRate() {
        let pointInMainScreen = self.convert(rateButton.center, to: nil)
        messageDelegate?.onRate(point: pointInMainScreen)
    }

    @objc func handleLongPress(recognizer: UILongPressGestureRecognizer) {
        if recognizer.state == .began {
            let pointInCell = recognizer.location(in: self)
            let pointOnMainScreen = self.convert(pointInCell, to: nil)
            messageDelegate?.onMessageLongPress(point: pointOnMainScreen)
        }
    }

    @objc func handleTap(recognizer: UILongPressGestureRecognizer) {
        let pointInCell = recognizer.location(in: self)
        let pointOnMainScreen = self.convert(pointInCell, to: nil)
        messageDelegate?.onQuoteTap(point: pointOnMainScreen)
    }

    public func enableShadow(enabled: Bool) {
        if enabled {
            showShadowView()
        } else {
            hideShadowView()
        }
    }

    func showShadowView() {
        shadowView.isHidden = false
        shadowView.layer.opacity = 0
        UIView.animate(withDuration: longPressAnmationDuration, animations: {
            self.shadowView.layer.opacity = 0.5
        })
    }

    func hideShadowView() {
        shadowView.layer.opacity = 0.5
        UIView.animate(withDuration: longPressAnmationDuration, animations: {
            self.shadowView.layer.opacity = 0
        }, completion: { (_) in
            self.shadowView.isHidden = true
        })
    }

    func flash() {
        messageView.flash()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        shadowView.frame = self.bounds

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

        var messageViewXPos: CGFloat = 0
        var rateButtonXPos: CGFloat = 0
        if model.horizontalPosition == .left {
            messageViewXPos = commentHorizontalPadding
            rateButtonXPos = self.contentView.bounds.width - rateButtonMargin - rateButtonSize.width
        } else if model.horizontalPosition == .right {
            var errorIcoSpace: CGFloat = 0
            if let status = model.sendingStatus, let icoImage = errorIcoView.image, status == .error {
                errorIcoSpace = commentHorizontalPadding + icoImage.size.width
            }
            messageViewXPos = self.contentView.bounds.width - commentHorizontalPadding - messageViewWidth - errorIcoSpace
            rateButtonXPos = rateButtonMargin
        }

        messageView.frame = CGRect(
               x: messageViewXPos,
               y: messageViewYPos,
               width: messageViewWidth,
               height: ArticleChatMessageView.calculateHeight(
                    message: model.body,
                    date: model.publishedAt,
                    quote: model.quote,
                    sendingStatus: model.sendingStatus,
                    width: messageViewWidth
               )
        )
        messageView.roundedRect(messageView.bounds, byRoundingCorners: cornerRadius(), cornerRadius: commentCornerRadiusSize)

        rateButton.frame = CGRect(x: rateButtonXPos, y: messageView.center.y - rateButtonSize.height/2, width: rateButtonSize.width, height: rateButtonSize.height
        )

        errorIcoView.center = CGPoint( x: messageView.frame.maxX + (self.contentView.bounds.maxX - messageView.frame.maxX)/2, y: messageView.frame.midY )
    }

    func cornerRadius() -> UIRectCorner {
        if model.verticalPosition == .single {
            if model.horizontalPosition == .left {
                return [.bottomLeft, .bottomRight, .topRight]
            } else if model.horizontalPosition == .right {
                return [.bottomLeft, .bottomRight, .topLeft]
            }
        } else if model.verticalPosition == .top {
            if model.horizontalPosition == .left {
                return [.topRight]
            } else if model.horizontalPosition == .right {
                return [.topLeft]
            }
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

    func applyColorScheme() {
        contentView.backgroundColor = UIColor.color(for: .otherBackground)
        rateButton.setImage(UIImage.schemeImage(for: "rating"), for: .normal)

        messageView.applyColorScheme()
        avatarView.applyColorScheme()
    }
}

extension ArticleChatCommentCell: ArticleChatConfigurable {

    public func configure(chatItem: ChatItem, chatItemDelegate: ChatItemDelegate?) {
        guard let chatComment = chatItem as? ChatComment else { return }
        self.model = chatComment
        self.messageDelegate = chatItemDelegate as? CommentDelegate

        messageView.setup(
            body: model.body,
            publishedAt: model.publishedAt,
            emotionsModel: model.emoutions,
            quote: model.quote,
            sendingStatus: model.sendingStatus,
            colorScheme: model.colorScheme
        )

        avatarView.setup(user: model.user)

        shadowView.isHidden = true
        rateButton.isHidden = model.sendingStatus != nil || !model.isCommentingOpen

        if let status = model.sendingStatus,
            status == .error {
            errorIcoView.isHidden = false
        } else {
            errorIcoView.isHidden = true
        }

        self.messageView.counterView.setNeedsLayout()
        self.messageView.counterView.layoutIfNeeded()

        applyColorScheme()
    }

    static func calculateCellHeight(chatItem: ChatItem, width: CGFloat) -> CGFloat {
        guard let model = chatItem as? ChatComment else { return 0 }
        let messageWidth = calculateMessageWidth(width: width)
        let avatarHeight = ArticleChatAvatarView.calculateCellHeight(user: model.user, width: messageWidth)
        let height = getCommentVerticalPadding()
                + avatarHeight
                + (avatarHeight > 0 ? getAvatarBottomMargin() : 0)
                + ArticleChatMessageView.calculateHeight(
                                                        message: model.body,
                                                        date: model.publishedAt,
                                                        quote: model.quote,
                                                        sendingStatus: model.sendingStatus,
                                                        width: messageWidth
                                                    )
                + getCommentVerticalPadding()

        return round(height)
    }
}

extension ArticleChatCommentCell: RecursiveLayout {

    func setNeedsLayoutRecursive() {
        self.setNeedsLayout()
        self.messageView.setNeedsLayout()
        self.messageView.counterView.setNeedsLayout()
        self.messageView.sendingView.setNeedsLayout()
    }

    func layoutIfNeedRecursive() {
        self.layoutIfNeeded()
        self.messageView.layoutIfNeeded()
        self.messageView.counterView.layoutIfNeeded()
        self.messageView.sendingView.layoutIfNeeded()
    }
}

extension ArticleChatCommentCell: Swipeable {
    func likeButtonOrigin() -> CGPoint {
        return rateButton.frame.origin
    }
}
