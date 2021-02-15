
import Foundation
import UIKit

struct FontStyle {
    var scale: CGFloat
    var ratioFont: UIFont {
        let fontSize = (CGFloat(self.fontSize) * scale).rounded(.up)
        return UIFont(name: self.familyName, size: fontSize) ?? UIFont.systemFont(ofSize: UIFont.systemFontSize)
    }

    private(set) var font: UIFont
    private(set) var lineHeightMultiple: CGFloat

    private var familyName: String
    private var fontSize: Int
    private var lineSpacing: Double?

    func attributeText(for string: String?) -> NSAttributedString {
        let string = string ?? ""
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = lineHeightMultiple
        paragraphStyle.lineBreakMode = .byTruncatingTail

        return NSAttributedString.init(string: string, attributes: [.font: font, .paragraphStyle: paragraphStyle])
    }

    func ratioAttributeText(for string: String?) -> NSAttributedString {
        let string = string ?? ""
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = lineHeightMultiple
        paragraphStyle.lineBreakMode = .byTruncatingTail

        return NSAttributedString.init(string: string, attributes: [.font: ratioFont, .paragraphStyle: paragraphStyle])
    }

    func attributeText(for string: String?, textColor: UIColor, textAlignment: NSTextAlignment = .left) -> NSAttributedString {
        let string = string ?? ""
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = lineHeightMultiple
        paragraphStyle.lineBreakMode = .byTruncatingTail
        paragraphStyle.alignment = textAlignment

        return NSAttributedString.init(string: string, attributes: [.font: font,
                                                                    .foregroundColor: textColor,
                                                                    .paragraphStyle: paragraphStyle])
    }

    func ratioAttributeText(for string: String?, textColor: UIColor, textAlignment: NSTextAlignment = .left) -> NSAttributedString {
        let string = string ?? ""
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = lineHeightMultiple
        paragraphStyle.lineBreakMode = .byTruncatingTail
        paragraphStyle.alignment = textAlignment

        return NSAttributedString.init(string: string, attributes: [.font: ratioFont,
                                                                    .foregroundColor: textColor,
                                                                    .paragraphStyle: paragraphStyle])
    }
}

extension FontStyle: Decodable {

    enum CodingKeys: String, CodingKey {
        case familyName = "font-family"
        case fontSize = "font-size"
        case lineSpacing = "line-height-multiple"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.familyName = try container.decode(String.self, forKey: .familyName)
        self.fontSize = try container.decode(Int.self, forKey: .fontSize)
        self.lineSpacing = try? container.decode(Double.self, forKey: .lineSpacing)

        self.font = UIFont.init(name: familyName, size: CGFloat(fontSize)) ?? UIFont.systemFont(ofSize: UIFont.systemFontSize)
        self.lineHeightMultiple = CGFloat(lineSpacing ?? 1)
        self.scale = 1
    }
}
