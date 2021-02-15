
import Foundation
import UIKit

extension UIFont {

    static func SFDisplaySemibold(fontSize size: CGFloat) -> UIFont {
        return UIFont(name: "SF-Pro-Display-Semibold", size: size) ?? UIFont.systemFont(ofSize: size, weight: .semibold)
    }

    static func SFDisplayRegular(fontSize size: CGFloat) -> UIFont {
        return UIFont(name: "SF-Pro-Display-Regular", size: size) ?? UIFont.systemFont(ofSize: size, weight: .semibold)
    }

    static func SFSemibold(fontSize size: CGFloat) -> UIFont {
        return UIFont(name: "SFProText-Semibold", size: size) ?? UIFont.systemFont(ofSize: size, weight: .semibold)
    }

    static func SFRegular(fontSize size: CGFloat) -> UIFont {
        return UIFont(name: "SFProText-Regular", size: size) ?? UIFont.systemFont(ofSize: size, weight: .regular)
    }

    static func SFBold(fontSize size: CGFloat) -> UIFont {
        return UIFont(name: "SFProText-Bold", size: size) ?? UIFont.systemFont(ofSize: size, weight: .bold)
    }

    static func SFMedium(fontSize size: CGFloat) -> UIFont {
        return UIFont(name: "SFProText-Medium", size: size) ?? UIFont.systemFont(ofSize: size, weight: .medium)
    }
}
