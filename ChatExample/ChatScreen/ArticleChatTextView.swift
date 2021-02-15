
import Foundation
import UIKit

private let kTextFieldMargin = isPhone() ? UIEdgeInsets(top: 8, left: 7, bottom: 8, right: 7)
                                         : UIEdgeInsets(top: 8, left: 20, bottom: 8, right: 20)

private let kSendButtonMargin = isPhone() ? UIEdgeInsets(top: 10, left: 7, bottom: 10, right: 7)
                                          : UIEdgeInsets(top: 10, left: 7, bottom: 10, right: 20)
private let kSendButtonWidth: CGFloat = 36
private let kSendButtonHeight: CGFloat = 36

private let kTextValueTransitionDuration: CFTimeInterval = 0.2
private let kSendButtonAppearanceAnimationDuration: CFTimeInterval = 0.15

private let kEditTextPlaceholderIndent: CGFloat = isPhone() ? 12 : 17
private let kEditTextPlaceHolderFontColorStyle = ColorSchemeName.informationFont
private let kEditTextPlaceholderFontStyle = FontStyleName.paragraph1Chat

private let kEditTextFieldCornerRadius: CGFloat = 18

private let kEditTextFieldBackgroundColorStyle = ColorSchemeName.emotions
private let kEditTextFieldBorderColorStyle = ColorSchemeName.stroke
private let kEditTextFieldBorderWidth: CGFloat = 1
private let kEditTextFieldTextColorStyle = ColorSchemeName.font
private let kEditTextFieldFontStyle = FontStyleName.paragraph1Chat

private let kEditTextFieldContentInset = isPhone() ? UIEdgeInsets(top: 7, left: 7, bottom: 7, right: kSendButtonWidth)
                                                   : UIEdgeInsets(top: 7, left: 12, bottom: 7, right: kSendButtonWidth)

protocol ArticleChatTextViewDelegate: class {
    func shouldIncreaseInputFieldHeight() -> Bool
    func onSend(message: String)
}

class ArticleChatTextView: UIView {

    public weak var chatTextViewDelegate: ArticleChatTextViewDelegate?

    private (set) var textView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.layer.cornerRadius = kEditTextFieldCornerRadius
        textView.layer.borderWidth = kEditTextFieldBorderWidth
        textView.isScrollEnabled = false
        textView.clipsToBounds = true
        textView.textContainerInset = kEditTextFieldContentInset
        return textView
    }()

    private (set) var placeHolderView: UILabel = {
        let placeHolderView = UILabel()
        placeHolderView.translatesAutoresizingMaskIntoConstraints = false
        placeHolderView.text = NSLocalizedString("article_chat_send_view_placeholder", comment: "")
        return placeHolderView
    }()

    private (set) var sendButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage.schemeImage(for: "sendButtonEnabled"), for: .normal)
        button.isHidden = true
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        self.addSubview(textView)
        self.addSubview(placeHolderView)
        self.addSubview(sendButton)

        textView.font = UIFont.fontStyle(for: kEditTextFieldFontStyle).ratioFont
        placeHolderView.font = UIFont.fontStyle(for: kEditTextPlaceholderFontStyle).ratioFont

        self.textView.delegate = self
        sendButton.addTarget(self, action: #selector(onSend), for: .touchUpInside)

        textView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(kSendButtonMargin.top)
            make.bottom.equalToSuperview().offset(-kSendButtonMargin.bottom)
            make.height.greaterThanOrEqualTo(kSendButtonHeight)
            make.left.equalToSuperview().offset(kTextFieldMargin.left)
            make.right.equalToSuperview().offset(-kTextFieldMargin.right)
        }

        let txtHeight = max(textView.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)).height, kSendButtonHeight)

        sendButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(textView.snp.bottom).offset(-txtHeight/2)
            make.right.equalToSuperview().offset(-kSendButtonMargin.right)
            make.width.equalTo(kSendButtonWidth)
            make.height.equalTo(kSendButtonHeight)
        }

        sendButton.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)

        placeHolderView.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(textView).offset(kEditTextPlaceholderIndent)
        }

        applyColorScheme()
    }

    func setupView(message: String?) {
        self.textView.text = message
        textViewDidChange(self.textView)
    }

    func updateAppearance() {
        textView.font = UIFont.fontStyle(for: kEditTextFieldFontStyle).ratioFont
        placeHolderView.font = UIFont.fontStyle(for: kEditTextPlaceholderFontStyle).ratioFont
        updateSendButtonConstraints()
        textViewDidChange(self.textView)
    }

    @objc func onSend() {
        let text = self.textView.text!
        self.textView.text = ""
        textViewDidChange(self.textView)
        chatTextViewDelegate?.onSend(message: text)
        addTransitionAnimation()
        sendButton.isHidden = true
        placeHolderView.isHidden = false
    }

    private func updateSendButtonConstraints() {
        let txtHeight = max(textView.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)).height, kSendButtonHeight)

        sendButton.snp.updateConstraints { (make) in
            make.centerY.equalTo(textView.snp.bottom).offset(-txtHeight/2)
        }
    }

    private func addTransitionAnimation() {
        let animation = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animation.type = .fade
        animation.duration = kTextValueTransitionDuration
        self.layer.add(animation, forKey: "kCATransitionFade")
    }

    private func showSendButton() {
        if !sendButton.isHidden {
            return
        }

        self.sendButton.isHidden = false
        self.sendButton.alpha = 0
        self.placeHolderView.alpha = 1
        UIView.animate(withDuration: kSendButtonAppearanceAnimationDuration, animations: {
            self.sendButton.alpha = 1
            self.placeHolderView.alpha = 0
        }, completion: { (_) in
            self.placeHolderView.isHidden = false
        })
    }

    private func hideSendButton() {
        if sendButton.isHidden {
            return
        }

        self.sendButton.alpha = 1
        self.placeHolderView.alpha = 0
        self.placeHolderView.isHidden = false
        UIView.animate(withDuration: kSendButtonAppearanceAnimationDuration, animations: {
            self.sendButton.alpha = 0
            self.placeHolderView.alpha = 1
        }, completion: { (_) in
            self.sendButton.isHidden = true
        })
    }
}

extension ArticleChatTextView: UITextViewDelegate {

    func textViewDidChange(_ textView: UITextView) {
        if textView.text.count == 0 {
            self.hideSendButton()
        } else {
            self.showSendButton()
        }

        textView.isScrollEnabled = false

        let shouldIncreaseHeight = chatTextViewDelegate?.shouldIncreaseInputFieldHeight() ?? false
        let newSize = textView.sizeThatFits(CGSize(width: textView.frame.size.width, height: CGFloat.greatestFiniteMagnitude))

        if newSize.height > textView.frame.size.height && !shouldIncreaseHeight {
            textView.isScrollEnabled = true
            return
        }

        textView.snp.updateConstraints({ (make) in
            make.height.greaterThanOrEqualTo(max(newSize.height, kSendButtonHeight))
        })
    }
}

extension ArticleChatTextView: Skinable {
    func applyColorScheme() {
        textView.backgroundColor = UIColor.color(for: kEditTextFieldBackgroundColorStyle)
        textView.layer.borderColor = UIColor.color(for: kEditTextFieldBorderColorStyle).cgColor
        textView.textColor = UIColor.color(for: .font)

        placeHolderView.textColor = UIColor.color(for: kEditTextPlaceHolderFontColorStyle)

        textView.layer.borderColor = UIColor.color(for: kEditTextFieldBorderColorStyle).cgColor
        textView.textColor = UIColor.color(for: kEditTextFieldTextColorStyle)

        placeHolderView.textColor = UIColor.color(for: kEditTextPlaceHolderFontColorStyle)

        sendButton.setImage(UIImage.schemeImage(for: "sendButtonEnabled"), for: .normal)
    }
}
