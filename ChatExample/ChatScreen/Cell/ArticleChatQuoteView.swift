
import Foundation
import UIKit

private let kOtherMessageSchemeBackgroundColorStyle = ColorSchemeName.otherMessage
private let kMyMessageSchemeBackgroundColorStyle = ColorSchemeName.myMessage
private let kInFieldSchemeBackgroundColorStyle = ColorSchemeName.otherBackground

private let kNickNameFontStyle = FontStyleName.header5
private let kOtherMessageSchemeNickNameColorStyle = ColorSchemeName.font
private let kMyMessageSchemeNickNameColorStyle = ColorSchemeName.onSurfaceFont
private let kInFieldSchemeNickNameColorStyle = ColorSchemeName.font

private let kQuoteFontStyle = FontStyleName.paragraph2Reg
private let kOtherMessageSchemeQuoteColorStyle = ColorSchemeName.font
private let kMyMessageSchemeQuoteColorStyle = ColorSchemeName.onSurfaceFont
private let kInFieldSchemeQuoteColorStyle = ColorSchemeName.font

private let kOtherMessageSchemeDelimeterColorStyle = ColorSchemeName.primary
private let kMyMessageSchemeDelimeterColorStyle = ColorSchemeName.onSurfaceFont
private let kInFieldSchemeDelimeterColorStyle = ColorSchemeName.primary

private let kQuoteViewLinesCount = 2
private let kDelimeterWidth: CGFloat = 4
private let kDelimeterCornerRadius = CGSize(width: 2, height: 2)
private let kDelimeterRightMargin: CGFloat = 12

class ArticleChatQuoteView: UIView {

    private (set) var quote: ChatCommentQuote?

    private (set) var delimeterView: UIView = {
        let delimeter = UIView()
        return delimeter
    }()

    private (set) var nicknameView: UILabel = {
        let nickname = UILabel()
        return nickname
    }()

    private (set) var quoteView: UILabel = {
        let quote = UILabel()
        quote.numberOfLines = kQuoteViewLinesCount
        return quote
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        self.addSubview(delimeterView)
        self.addSubview(quoteView)
        self.addSubview(nicknameView)

        nicknameView.font = UIFont.fontStyle(for: kNickNameFontStyle).ratioFont
        quoteView.font = UIFont.fontStyle(for: kQuoteFontStyle).ratioFont
    }

    func setup(quote: ChatCommentQuote?) {
        self.quote = quote
        quoteView.text = quote?.parentBody
        nicknameView.text = quote?.parentUser?.nickName
        applyScheme(type: quote?.type ?? .inOtherMessage)

        nicknameView.font = UIFont.fontStyle(for: kNickNameFontStyle).ratioFont
        quoteView.font = UIFont.fontStyle(for: kQuoteFontStyle).ratioFont
    }

    func updateAppearance() {
        nicknameView.font = UIFont.fontStyle(for: kNickNameFontStyle).ratioFont
        quoteView.font = UIFont.fontStyle(for: kQuoteFontStyle).ratioFont
    }

    private func applyScheme(type: ChatCommentQuoteType) {
        if type == .inOtherMessage {
            quoteView.textColor = UIColor.color(for: kOtherMessageSchemeQuoteColorStyle)
            quoteView.backgroundColor = UIColor.color(for: kOtherMessageSchemeBackgroundColorStyle)

            nicknameView.textColor = UIColor.color(for: kOtherMessageSchemeNickNameColorStyle)
            nicknameView.backgroundColor = UIColor.color(for: kOtherMessageSchemeBackgroundColorStyle)

            delimeterView.backgroundColor = UIColor.color(for: kOtherMessageSchemeDelimeterColorStyle)

            self.backgroundColor = UIColor.color(for: kOtherMessageSchemeBackgroundColorStyle)
        } else if type == .inMyMessage {
            quoteView.textColor = UIColor.color(for: kMyMessageSchemeQuoteColorStyle)
            quoteView.backgroundColor = UIColor.color(for: kMyMessageSchemeBackgroundColorStyle)

            nicknameView.textColor = UIColor.color(for: kMyMessageSchemeNickNameColorStyle)
            nicknameView.backgroundColor = UIColor.color(for: kMyMessageSchemeBackgroundColorStyle)

            delimeterView.backgroundColor = UIColor.color(for: kMyMessageSchemeDelimeterColorStyle)

            self.backgroundColor = UIColor.color(for: kMyMessageSchemeBackgroundColorStyle)
        } else if type == .inSendField {
            quoteView.textColor = UIColor.color(for: kInFieldSchemeQuoteColorStyle)
            quoteView.backgroundColor = UIColor.color(for: kInFieldSchemeBackgroundColorStyle)

            nicknameView.textColor = UIColor.color(for: kInFieldSchemeNickNameColorStyle)
            nicknameView.backgroundColor = UIColor.color(for: kInFieldSchemeBackgroundColorStyle)

            delimeterView.backgroundColor = UIColor.color(for: kInFieldSchemeDelimeterColorStyle)

            self.backgroundColor = UIColor.color(for: kInFieldSchemeBackgroundColorStyle)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let widthWithoutDelimeter = self.bounds.width - kDelimeterWidth - kDelimeterRightMargin

        delimeterView.frame = CGRect(
            x: 0,
            y: 0,
            width: kDelimeterWidth,
            height: self.bounds.height
        )

        delimeterView.roundedRect(delimeterView.bounds, byRoundingCorners: [.allCorners], cornerRadius: kDelimeterCornerRadius)

        nicknameView.frame = CGRect(
            x: kDelimeterWidth + kDelimeterRightMargin,
            y: 0,
            width: widthWithoutDelimeter,
            height: quote?.parentUser?.nickName.boundingSize(
                with: widthWithoutDelimeter,
                attributes: [.font: UIFont.fontStyle(for: kNickNameFontStyle).ratioFont]
            ).height ?? 0
        )

        quoteView.frame = CGRect(
            x: kDelimeterWidth + kDelimeterRightMargin,
            y: nicknameView.frame.maxY,
            width: widthWithoutDelimeter,
            height: ArticleChatQuoteView.calculateHeight(
                text: quote?.parentBody,
                width: widthWithoutDelimeter,
                font: UIFont.fontStyle(for: kQuoteFontStyle).ratioFont,
                linesCount: kQuoteViewLinesCount
            )
        )
    }

    static func calculateHeight(quote: ChatCommentQuote?, width: CGFloat) -> CGFloat {
        if let quoteText = quote?.parentBody, let nicknameText = quote?.parentUser?.nickName {
            let widthWithoutDelimeter = width - kDelimeterWidth - kDelimeterRightMargin
            let nickNameSize = nicknameText.boundingSize(
                with: widthWithoutDelimeter,
                attributes: [.font: UIFont.fontStyle(for: kNickNameFontStyle).ratioFont]
            )
            return nickNameSize.height + calculateHeight(
                                                    text: quoteText,
                                                    width: widthWithoutDelimeter,
                                                    font: UIFont.fontStyle(for: kQuoteFontStyle).ratioFont,
                                                    linesCount: kQuoteViewLinesCount
                                                )
        }
        return 0
    }

    private static func calculateHeight(text: String?, width: CGFloat, font: UIFont, linesCount: Int) -> CGFloat {
        guard let text = text else { return 0 }
        let textSize = text.boundingSize(with: width, attributes: [.font: font])
        let currentLinesCount = min(textSize.height/font.lineHeight, CGFloat(linesCount))
        return ceil(currentLinesCount*font.lineHeight)
    }
}

extension ArticleChatQuoteView: Skinable {
    func applyColorScheme() {
        applyScheme(type: quote?.type ?? .inOtherMessage)
    }
}
