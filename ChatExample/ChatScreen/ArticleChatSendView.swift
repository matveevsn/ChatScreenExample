
import Foundation
import UIKit

private let kBackgroundColorStyle = ColorSchemeName.otherBackground
private let kSeparatorBackgroundColorStyle = ColorSchemeName.stroke

private let kSeparatorHeight: CGFloat = 1
private let kSendFieldMargin = isPhone() ? UIEdgeInsets(top: 8, left: 7, bottom: 8, right: 7) : UIEdgeInsets(top: 12, left: 20, bottom: 12, right: 20)
private let kCloseButtonContentInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
private let kCloseButtonMargins = isPhone() ? UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 25) : UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 38)

protocol SendViewDelegate: class {
    func shouldIncreaseInputFieldHeight() -> Bool
    func onCloseQuote()
    func onSend(message: String)
}

extension ArticleChatSendView: Skinable {
    func applyColorScheme() {
        self.backgroundColor = UIColor.color(for: kBackgroundColorStyle)
        topSeparator.backgroundColor = UIColor.color(for: kSeparatorBackgroundColorStyle)

        quoteView.applyColorScheme()
        textView.applyColorScheme()

        closeButton.setImage(SkinManager.schemeImage(for: "quoteCloseButton"), for: .normal)
    }
}

class ArticleChatSendView: SeparatorView {

    public weak var sendViewDelegate: SendViewDelegate?
    private var quote: ChatCommentQuote?

    private (set) var quoteView: ArticleChatQuoteView = {
        let quoteView = ArticleChatQuoteView()
        quoteView.translatesAutoresizingMaskIntoConstraints = false
        return quoteView
    }()

    private (set) var closeButton: UIButton = {
        let closeButton = UIButton()
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.setImage(SkinManager.schemeImage(for: "quoteCloseButton"), for: .normal)
        closeButton.contentEdgeInsets = kCloseButtonContentInsets
        closeButton.isHidden = true
        return closeButton
    }()

    private (set) var textView: ArticleChatTextView = {
        let textView = ArticleChatTextView(frame: .zero)
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()

    init(frame: CGRect) {
        super.init(topSeparator: true)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    internal override func setupView() {
        super.setupView()

        self.addSubview(quoteView)
        self.addSubview(closeButton)
        self.addSubview(textView)

        textView.chatTextViewDelegate = self
        closeButton.addTarget(self, action: #selector(onClose), for: .touchUpInside)

        let quoteHeight = ArticleChatQuoteView.calculateHeight(quote: quote, width: self.bounds.width)
        quoteView.snp.makeConstraints { (make) in
            make.top.equalTo(self).offset(quoteHeight > 0 ? kSendFieldMargin.top : 0)
            make.height.equalTo(quoteHeight)
            make.left.equalTo(self).offset(kSendFieldMargin.left)
            make.right.equalTo(closeButton.snp.left).offset(-kCloseButtonMargins.left)
        }

        closeButton.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.snp.right).offset(-kCloseButtonMargins.right)
            make.centerY.equalTo(quoteView.snp.centerY)
        }

        textView.snp.makeConstraints { (make) in
            make.top.equalTo(quoteView.snp.bottom)
            make.bottom.equalTo(self)
            make.left.equalTo(self)
            make.right.equalTo(self)
        }
    }

    private func setupQuote(quote: ChatCommentQuote?) {
        self.quote = quote
        closeButton.isHidden = quote == nil

        quoteView.setup(quote: quote)

        let quoteHeight = ArticleChatQuoteView.calculateHeight(quote: quote, width: self.quoteView.bounds.width)
        quoteView.snp.updateConstraints { (make) in
            make.height.equalTo(quoteHeight)
            make.top.equalTo(self).offset(quoteHeight > 0 ? kSendFieldMargin.top : 0)
        }
    }

    private func updateQuoteConstraints() {
        let quoteHeight = ArticleChatQuoteView.calculateHeight(quote: quote, width: self.bounds.width)
        quoteView.snp.updateConstraints { (make) in
            make.height.equalTo(quoteHeight)
        }
    }

    @objc func onClose() {
        sendViewDelegate?.onCloseQuote()
    }

    public func setup(quote: ChatCommentQuote?) {
        setupQuote(quote: quote)
    }

    public func setup(message: String?) {
        textView.setupView(message: message)
    }

    public func clear() {
        setupQuote(quote: nil)
    }

    public func dismissKeyboardIfNeed() -> Bool {
        if textView.textView.isFirstResponder {
            textView.textView.resignFirstResponder()
            return true
        }
        return false
    }

    public func showKeyboard() {
        textView.textView.becomeFirstResponder()
    }
}

extension ArticleChatSendView: ArticleChatTextViewDelegate {
    func shouldIncreaseInputFieldHeight() -> Bool {
        return sendViewDelegate?.shouldIncreaseInputFieldHeight() ?? false
    }

    func onSend(message: String) {
        sendViewDelegate?.onSend(message: message)
    }
}

extension ArticleChatSendView: ArticleChatScreenAppearanceUpdate {
    public func updateAppearance() {
        quoteView.updateAppearance()
        textView.updateAppearance()
        updateQuoteConstraints()
    }
}
