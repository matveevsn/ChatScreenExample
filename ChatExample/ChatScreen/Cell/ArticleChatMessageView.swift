
import Foundation
import UIKit

private let kMessageQuotePadding = isPhone() ? UIEdgeInsets(top: 10, left: 10, bottom: 0, right: 10) : UIEdgeInsets(top: 12, left: 12, bottom: 0, right: 12)
private let kMessagePadding = isPhone() ? UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10) : UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
private let kMessageDatePadding = isPhone() ? UIEdgeInsets(top: 5, left: 10, bottom: 10, right: 10) : UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
private let kMessageCounterPadding = isPhone() ? UIEdgeInsets(top: 5, left: 0, bottom: 10, right: 10) : UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)

private let kWhiteSchemeMessageBackgroundColorStyle = ColorSchemeName.otherMessage
private let kBlueSchemeMessageBackgroundColorStyle = ColorSchemeName.myMessage
private let kGraySchemeMessageBackgroundColorStyle = ColorSchemeName.chatReport

private let kWhiteSchemeMessageTextColorStyle = ColorSchemeName.font
private let kBlueSchemeMessageTextColorStyle = ColorSchemeName.onSurfaceFont
private let kGraySchemeMessageTextColorStyle = ColorSchemeName.font

private let kWhiteSchemeDateTextColorStyle = ColorSchemeName.informationFont
private let kBlueSchemeDateTextColorStyle = ColorSchemeName.myMessageFont

private let kMessageTextFontStyle = FontStyleName.paragraph1Chat
private let kMessageDateFontStyle = FontStyleName.paragraph2Reg

private let kFlashAnmationDuration = 0.5

extension ArticleChatMessageView: Skinable {
    func applyColorScheme() {
        if colorScheme == .white {
            self.backgroundColor = UIColor.color(for: kWhiteSchemeMessageBackgroundColorStyle)
            message.backgroundColor = UIColor.color(for: kWhiteSchemeMessageBackgroundColorStyle)
            message.textColor = UIColor.color(for: kWhiteSchemeMessageTextColorStyle)
            date.backgroundColor = UIColor.color(for: kWhiteSchemeMessageBackgroundColorStyle)
            date.textColor = UIColor.color(for: kWhiteSchemeDateTextColorStyle)
            flashView.backgroundColor = UIColor.color(for: kBlueSchemeMessageBackgroundColorStyle)
        } else if colorScheme == .blue {
            self.backgroundColor = UIColor.color(for: kBlueSchemeMessageBackgroundColorStyle)
            message.backgroundColor = UIColor.color(for: kBlueSchemeMessageBackgroundColorStyle)
            message.textColor = UIColor.color(for: kBlueSchemeMessageTextColorStyle)
            date.backgroundColor = UIColor.color(for: kBlueSchemeMessageBackgroundColorStyle)
            date.textColor = UIColor.color(for: kBlueSchemeDateTextColorStyle)
            flashView.backgroundColor = UIColor.color(for: kWhiteSchemeMessageBackgroundColorStyle)
        } else if colorScheme == .gray {
            self.backgroundColor = UIColor.color(for: kGraySchemeMessageBackgroundColorStyle)
            message.backgroundColor = UIColor.color(for: kGraySchemeMessageBackgroundColorStyle)
            message.textColor = UIColor.color(for: kGraySchemeMessageTextColorStyle)
        }
    }
}

class ArticleChatMessageView: UIView {

    private var body: String!
    private var publishedAt: String?
    private var emotions: EmotionsModel?
    private var quote: ChatCommentQuote?
    private var sendingStatus: SendingStatus?
    private var colorScheme: CommentColorScheme!

    private (set) var quoteView: ArticleChatQuoteView = {
        let quoteView = ArticleChatQuoteView()
        return quoteView
    }()

    private (set) var message: UILabel = {
        let message = UILabel()
        message.numberOfLines = 0
        return message
    }()

    private (set) var date: UILabel = {
        let date = UILabel()
        return date
    }()

    private (set) var sendingView: ArticleChatMessageProcessView = {
        let sendingView = ArticleChatMessageProcessView()
        return sendingView
    }()

    private (set) var counterView: ArticleChatEmotionsCountView = {
        let counterView = ArticleChatEmotionsCountView()
        return counterView
    }()

    private (set) var flashView: UIView = {
        let flashView = UIView(frame: .zero)
        flashView.isHidden = true
        return flashView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        self.addSubview(quoteView)
        self.addSubview(message)
        self.addSubview(date)
        self.addSubview(sendingView)
        self.addSubview(counterView)
        self.addSubview(flashView)

        message.font = UIFont.fontStyle(for: kMessageTextFontStyle).ratioFont
        date.font = UIFont.fontStyle(for: kMessageDateFontStyle).ratioFont
    }

    public func setup(body: String, publishedAt: String?, emotionsModel: EmotionsModel?, quote: ChatCommentQuote?, sendingStatus: SendingStatus?, colorScheme: CommentColorScheme) {
        self.body = body
        self.publishedAt = publishedAt
        self.emotions = emotionsModel
        self.quote = quote
        self.sendingStatus = sendingStatus
        self.colorScheme = colorScheme

        message.text = body
        date.text = publishedAt
        date.isHidden = sendingStatus != nil
        counterView.setup(model: emotions, colorScheme: colorScheme)

        var count = 0
        if let emoutionsValues = emotionsModel?.emotions?.compactMap({$0.count}) {
            count = emoutionsValues.reduce(0) { $0 + $1}
        }
        counterView.isHidden = count == 0
        sendingView.isHidden = sendingStatus == nil

        if let status = sendingStatus {
            sendingView.setupView(sendingStatus: status, colorScheme: colorScheme)
        }

        quoteView.setup(quote: quote)
        applyColorScheme()

        message.font = UIFont.fontStyle(for: kMessageTextFontStyle).ratioFont
        date.font = UIFont.fontStyle(for: kMessageDateFontStyle).ratioFont
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        quoteView.frame = CGRect(
            x: kMessageQuotePadding.left,
            y: kMessageQuotePadding.top,
            width: self.bounds.width - kMessageQuotePadding.left - kMessageQuotePadding.right,
            height: ArticleChatQuoteView.calculateHeight(
                quote: self.quote,
                width: self.bounds.width - kMessageQuotePadding.left - kMessageQuotePadding.right
            )
        )

        message.frame = CGRect(
            x: kMessagePadding.left,
            y: quoteView.frame.height > 0 ? quoteView.frame.maxY + kMessageQuotePadding.bottom + kMessagePadding.top : kMessagePadding.top,
            width: self.bounds.width - kMessagePadding.left - kMessagePadding.right,
            height: body.boundingSize(
                with: self.bounds.width - kMessagePadding.left - kMessagePadding.right,
                attributes: [ .font: UIFont.fontStyle(for: kMessageTextFontStyle).ratioFont ]
            ).height
        )

        flashView.frame = self.bounds

        date.frame = CGRect(
            x: kMessageDatePadding.left,
            y: message.frame.maxY + kMessageDatePadding.top,
            width: ((self.bounds.width - kMessageDatePadding.left - kMessageDatePadding.right)/2).rounded(.up),
            height: (publishedAt?.boundingSize(
                with: ((self.bounds.width - kMessageDatePadding.left - kMessageDatePadding.right)/2).rounded(.up),
                attributes: [ .font: UIFont.fontStyle(for: kMessageDateFontStyle).ratioFont ]
            ) ?? .zero).height
        )

        sendingView.frame = CGRect(
            x: kMessageDatePadding.left,
            y: message.frame.maxY + kMessageDatePadding.top,
            width: (self.bounds.width - kMessageDatePadding.left - kMessageDatePadding.right)/2,
            height: ArticleChatMessageProcessView.calculateSize(sendingStatus: sendingStatus).height
        )

        let counterViewSize = ArticleChatEmotionsCountView.calculateSize(model: self.emotions, colorScheme: colorScheme)
        counterView.frame = CGRect(
            x: kMessageDatePadding.left + ((self.bounds.width - kMessageDatePadding.left - kMessageDatePadding.right)/2).rounded(.up),
            y: message.frame.maxY + kMessageCounterPadding.top,
            width: ((self.bounds.width - kMessageDatePadding.left - kMessageDatePadding.right)/2).rounded(.up),
            height: counterViewSize.height
        )
    }

    static func calculateHeight(message: String, date: String?, quote: ChatCommentQuote?, sendingStatus: SendingStatus?, width: CGFloat) -> CGFloat {

        let quoteHeight = ArticleChatQuoteView.calculateHeight(
            quote: quote,
            width: width - kMessageQuotePadding.left - kMessageQuotePadding.right
        )

        let messageSize = message.boundingSize(
            with: width - kMessagePadding.left - kMessagePadding.right,
            attributes: [ .font: UIFont.fontStyle(for: kMessageTextFontStyle).ratioFont ]
        )

        let dateSize = date?.boundingSize(
            with: ((width - kMessageDatePadding.left - kMessageDatePadding.right)/2).rounded(),
            attributes: [ .font: UIFont.fontStyle(for: kMessageDateFontStyle).ratioFont ]
            ) ?? .zero

        let sendingStatusSize = ArticleChatMessageProcessView.calculateSize(sendingStatus: sendingStatus)

        return (quoteHeight > 0 ? kMessageQuotePadding.top + quoteHeight + kMessageQuotePadding.bottom : 0)
            + (messageSize.height > 0 ? kMessagePadding.top + messageSize.height + (dateSize.height > 0 || sendingStatusSize.height > 0 ? 0 : kMessagePadding.bottom) : 0)
            + (dateSize.height > 0 ? kMessageDatePadding.top + dateSize.height + kMessageDatePadding.bottom : 0)
            + (sendingStatusSize.height > 0 ? kMessageDatePadding.top + sendingStatusSize.height + kMessageDatePadding.bottom : 0)
    }

    func flash() {
        flashView.isHidden = false
        flashView.layer.opacity = 0.5
        UIView.animate(withDuration: kFlashAnmationDuration, animations: {
            self.flashView.layer.opacity = 0
        }, completion: { (_) in
            self.flashView.isHidden = true
        })
    }
}
