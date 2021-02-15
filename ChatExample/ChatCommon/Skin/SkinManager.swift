
import Foundation
import UIKit

private let darkModeKey = "dark-mode-key"
private let fontScaleKey = "font-scale-key"
private let decoreTypeKey = "decor-type-key"

class SkinManager {
    static let shared: SkinManager = SkinManager()

    private let fontMap: [String: FontStyle]
    private let colorMap: [String: ColorScheme]

    static var isDarkMode: Bool {
        switch SkinManager.decorType {
        case .system:
            if #available(iOS 13.0, *) {
                return UIScreen.main.traitCollection.userInterfaceStyle == .dark
            }
            return false
        case .light:
            return false
        case .dark:
            return true
        }
    }

    var fontScale: FontScale {
        set {
            let uDefaults = UserDefaults.standard
            uDefaults.set(newValue.rawValue, forKey: fontScaleKey)
            uDefaults.synchronize()
            
            NotificationCenter.default.post(name: .fontScaleChanged, object: nil)
        }
        get {
            let fontScaleRaw = (UserDefaults.standard.value(forKey: fontScaleKey) as? Float) ?? 1
            return FontScale.init(rawValue: fontScaleRaw) ?? .small
        }
    }

    var isLargeScale: Bool {
        if !isPhone() { return false }
        
        return fontScale == .xLarge || fontScale == .xxLarge
    }

    static var decorType: DecorType {
        set {
            save(value: newValue.rawValue, key: decoreTypeKey)
            NotificationCenter.default.post(name: .decorTypeChanged, object: nil)
        }
        get {
            guard let typeRaw = (value(by: decoreTypeKey) as? String) else { return .system }
            
            return DecorType.init(rawValue: typeRaw) ?? .system
        }
    }

    private init() {
        let resourceName = "Skin_" + (isPhone() ? "iPhone" : "IPad")
        let skinPath = Bundle.main.path(forResource: resourceName, ofType: "json") ?? ""
        let url = URL.init(fileURLWithPath: skinPath)

        do {
            let data = try Data.init(contentsOf: url)
            let decoder = JSONDecoder()
            colorMap = try decoder.decode(Dictionary<String, ColorScheme>.self, from: data, keyedBy: "colors")
            fontMap = try decoder.decode(Dictionary<String, FontStyle>.self, from: data, keyedBy: "fonts")
        } catch {
            fatalError("CAN'T OPEN THE SKIN.JSON \(error)")
        }
    }

    func fontStyle(with name: String) -> FontStyle {
        guard var fontStyle = fontMap[name] else {
            fatalError("FONT STYLE WITH NAME: \(name) NOT FOUND")
        }

        fontStyle.scale = CGFloat(fontScale.rawValue)
        return fontStyle
    }

    func color(with name: String) -> UIColor {
        guard let colorScheme = colorMap[name] else {
            fatalError("COLOR SCHEME WITH NAME: \(name) NOT FOUND")
        }

        return SkinManager.isDarkMode ? colorScheme.dark : colorScheme.light
    }

    static func schemeImage(for imageNamed: String) -> UIImage? {
        let colorSchemeImageNamed = SkinManager.isDarkMode ? imageNamed + "_variant" : imageNamed
        return UIImage(named: colorSchemeImageNamed)
    }
    
    static private func save(value: Any, key: String) {
        let uDefaults = UserDefaults.standard
        uDefaults.setValue(value, forKey: key)
        uDefaults.synchronize()
    }
    
    static private func value(by key: String) -> Any? {
        return UserDefaults.standard.value(forKey: key)
    }
}

extension Notification.Name {
    static let fontScaleChanged = Notification.Name("font-scale-changed")
    static let decorTypeChanged = Notification.Name("decor-type-changed")
}
