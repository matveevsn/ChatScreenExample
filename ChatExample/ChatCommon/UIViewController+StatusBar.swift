
import Foundation
import UIKit

extension UIViewController {
    var statusBarStyle: UIStatusBarStyle {
        var statusBarStyle = SkinManager.isDarkMode ? UIStatusBarStyle.lightContent : UIStatusBarStyle.default
        if #available(iOS 13.0, *) {
            statusBarStyle = SkinManager.isDarkMode ? UIStatusBarStyle.lightContent : UIStatusBarStyle.darkContent
        }
        return statusBarStyle
    }
}
