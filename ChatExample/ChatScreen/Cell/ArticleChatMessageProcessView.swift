
import Foundation
import UIKit

private let kWhiteSchemeBackgroundColorStyle = ColorSchemeName.otherBackground
private let kBlueSchemeBackgroundColorStyle = ColorSchemeName.myMessage

private let kWhiteSchemeUnsendTitleColorStyle = ColorSchemeName.informationFont
private let kBlueSchemeUnsendTitleColorStyle = ColorSchemeName.myMessageFont

private let kUnsendTitleFontStyle = FontStyleName.paragraph2Reg

private let kClockSize = CGSize(width: 12, height: 12)
private let kClockRightPadding: CGFloat = 5

class ArticleChatMessageProcessView: UIView {

    private var sendingStatus: SendingStatus = .progress
    private var colorScheme: CommentColorScheme = .white

    private (set) var clockView: UIImageView = {
        let clockView = UIImageView(image: UIImage(named: "clock"))
        return clockView
    }()

    private (set) var title: UILabel = {
        let title = UILabel()
        title.numberOfLines = 1
        title.textAlignment = .center
        title.text = NSLocalizedString("article_chat_sending_title", comment: "")
        return title
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        self.addSubview(clockView)
        self.addSubview(title)

        title.font = UIFont.fontStyle(for: kUnsendTitleFontStyle).ratioFont
        title.textColor = UIColor.color(for: kBlueSchemeUnsendTitleColorStyle)
    }

    public func setupView(sendingStatus: SendingStatus, colorScheme: CommentColorScheme) {
        self.sendingStatus = sendingStatus
        self.colorScheme = colorScheme

        if colorScheme == .white {
            self.backgroundColor = UIColor.color(for: kWhiteSchemeBackgroundColorStyle)
            self.title.backgroundColor = UIColor.color(for: kWhiteSchemeBackgroundColorStyle)
            title.textColor = UIColor.color(for: kWhiteSchemeUnsendTitleColorStyle)
        } else if colorScheme == .blue {
            self.backgroundColor = UIColor.color(for: kBlueSchemeBackgroundColorStyle)
            self.title.backgroundColor = UIColor.color(for: kBlueSchemeBackgroundColorStyle)
            title.textColor = UIColor.color(for: kBlueSchemeUnsendTitleColorStyle)
        }

        clockView.isHidden = sendingStatus != .progress

        switch sendingStatus {
        case .progress:
            title.text = NSLocalizedString("article_chat_sending_title", comment: "")
        case .error:
            title.text = NSLocalizedString("article_chat_error_title", comment: "")
        }

        title.font = UIFont.fontStyle(for: kUnsendTitleFontStyle).ratioFont
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        clockView.frame = CGRect(x: 0, y: 0, width: kClockSize.width, height: kClockSize.height)

        let titleSize = title.text!.boundingSize(
            with: .greatestFiniteMagnitude,
            attributes: [.font: title.font!]
        )

        title.frame = CGRect(
            x: sendingStatus == .progress ? clockView.frame.maxX + kClockRightPadding : 0,
            y: 0,
            width: titleSize.width,
            height: titleSize.height
        )
    }

    static func calculateSize(sendingStatus: SendingStatus?) -> CGSize {
        guard let status = sendingStatus else { return .zero }
        let titleSize = NSLocalizedString("article_chat_sending_title", comment: "").boundingSize(
            with: .greatestFiniteMagnitude,
            attributes: [.font: UIFont.fontStyle(for: kUnsendTitleFontStyle).ratioFont]
        )
        return CGSize(width: round(status == .progress ? kClockSize.width + kClockRightPadding + titleSize.width : titleSize.width), height: max(kClockSize.height, round(titleSize.height)))
    }
}
