
import Foundation
import UIKit

extension String {
    func boundingSize(with size: CGSize, options lineOptions: NSStringDrawingOptions, attributes: [NSAttributedString.Key: Any]) -> CGSize {
        let tmp = NSMutableAttributedString(string: self, attributes: attributes)
        let contentSize = tmp.boundingRect(with: size, options: lineOptions/*.usesLineFragmentOrigin*/, context: nil).size
        return CGSize.init(width: contentSize.width.rounded(.up), height: contentSize.height.rounded(.up))
    }

    func boundingSize(with width: CGFloat, attributes: [NSAttributedString.Key: Any]) -> CGSize {
        let size = CGSize.init(width: width, height: .greatestFiniteMagnitude)
        return boundingSize(with: size, options: .usesLineFragmentOrigin, attributes: attributes)
    }

    var stableHash: Int {
        let unicodeScalars = self.unicodeScalars.map { $0.value }
        return unicodeScalars.reduce(5381) {
            ($0 << 5) &+ $0 &+ Int($1)
        }
    }

    func toInsets() -> UIEdgeInsets {
        let values = toArrayDouble()
        if values.count < 4 { return .zero }

        return UIEdgeInsets(top: CGFloat(values[0]), left: CGFloat(values[1]), bottom: CGFloat(values[2]), right: CGFloat(values[3]))
    }

    func toSize() -> CGSize {
        let values = toArrayDouble()
        if values.count < 2 { return .zero }

        return CGSize.init(width: values[0], height: values[1])
    }

    private func toArrayDouble() -> [Double] {
        let charSet = CharacterSet.init(charactersIn: "()")
        let components = trimmingCharacters(in: charSet).replacingOccurrences(of: " ", with: "").components(separatedBy: ",")

        let values = components.compactMap { Double($0) }

        return values
    }
}

extension NSAttributedString {
    func boundingSize(size: CGSize, options lineOptions: NSStringDrawingOptions = [NSStringDrawingOptions.usesLineFragmentOrigin, .truncatesLastVisibleLine]) -> CGSize {
        if string.isEmpty { return .zero }

        let attributes = self.attributes(at: 0, effectiveRange: nil)
        let attString = NSAttributedString.init(string: string, attributes: attributes)

        var modifAttributes = attString.attributes(at: 0, effectiveRange: nil)
        let paragraphStyle: NSParagraphStyle? = attributes[.paragraphStyle] as? NSParagraphStyle
        let mParagraphStyle = paragraphStyle?.mutableCopy() as? NSMutableParagraphStyle
        mParagraphStyle?.lineBreakMode = .byWordWrapping

        modifAttributes[.paragraphStyle] = mParagraphStyle

        let aString = NSAttributedString.init(string: string, attributes: modifAttributes)

        let contentSize = aString.boundingRect(with: size, options: lineOptions, context: nil).size
        return CGSize.init(width: contentSize.width.rounded(.up), height: contentSize.height.rounded(.up))
    }

    func boundingSize(width: CGFloat) -> CGSize {
        let size = CGSize.init(width: width, height: .infinity)
        return boundingSize(size: size, options: [NSStringDrawingOptions.usesLineFragmentOrigin, NSStringDrawingOptions.truncatesLastVisibleLine])
    }
}
