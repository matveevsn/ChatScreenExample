
import Foundation
import UIKit

enum FontStyleName: String {
    case header1
    case header2
    case header2Reg
    case header3
    case header4
    case header4Reg
    case header5
    case paragraph1
    case paragraph1Reg
    case paragraph1Chat
    case paragraph2
    case paragraph2Reg
    case paragraph3 // ? не используется
    case paragraph3Reg
}

enum ColorSchemeName: String {
    case primary
    case background
    case backgroundSecondary
    case error
    case card
    case font
    case informationFont
    case secondaryFont
    case informer
    case informerHover
    case onSurfaceFont
    case emotions
    case otherBackground
    case myMessage
    case myMessageFont
    case otherMessage
    case chatReport
    case stroke
    case purpleGray
    case scrollBackground
    case scrollSlider
    case otherBackgroundSecondary
    case buttonContrast
    case buttonContrastSecondary
}

enum FontScale: Float, CaseIterable {
    case small = 1
    case medium = 1.125
    case large = 1.25
    case xLarge = 1.375
    case xxLarge = 1.5

    var index: Int? {
        return FontScale.allCases.firstIndex(of: self)
    }
}

enum DecorType: String, CaseIterable {
    case system
    case light
    case dark
}

protocol Skinable {
    func applyColorScheme()
    var isDark: Bool { get }
}

extension Skinable {
    var isDark: Bool {
        return SkinManager.isDarkMode
    }
}

protocol SkinableController {
    func applySkin()
}

extension UIViewController {
    func applyNavigationBarSkin() {
        navigationController?.navigationBar.barTintColor = UIColor.color(for: .otherBackground)
        navigationController?.navigationBar.tintColor = UIColor.color(for: .primary)
        navigationController?.navigationBar.isTranslucent = false

        let navbatAttribute = [NSAttributedString.Key.font: UIFont.fontStyle(for: .header4).font,
                               NSAttributedString.Key.foregroundColor: UIColor.color(for: .font)]
        navigationController?.navigationBar.titleTextAttributes = navbatAttribute
        navigationController?.navigationBar.shadowImage = Self.shadowImage.alpha(0)
    }

    static var shadowImage: UIImage {
        return UIColor.color(for: .stroke).image(size: CGSize(width: 1, height: 1))
    }

    func updateShadowNavbar(percent: CGFloat) {
        navigationController?.navigationBar.shadowImage = Self.shadowImage.alpha(percent)
    }
}

extension UIImage {
    func alpha(_ value: CGFloat) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(at: CGPoint.zero, blendMode: .normal, alpha: value)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
}

extension UIFont {
    static func fontStyle(for styleName: FontStyleName) -> FontStyle {
        return SkinManager.shared.fontStyle(with: styleName.rawValue)
    }
}

extension UIColor {
    static func color(for schemeName: ColorSchemeName) -> UIColor {
        return SkinManager.shared.color(with: schemeName.rawValue)
    }
}

extension UIActivityIndicatorView {
    static var preferStyle: UIActivityIndicatorView.Style {
        return SkinManager.isDarkMode ? UIActivityIndicatorView.Style.white : UIActivityIndicatorView.Style.gray
    }
}

extension UINavigationBar {
    static var navigationBarStyle: UIBarStyle {
        return SkinManager.isDarkMode ? .black : .default
    }
}

extension UIImage {
    static func schemeImage(for imageNamed: String) -> UIImage? {
        return SkinManager.schemeImage(for: imageNamed)
    }
}
