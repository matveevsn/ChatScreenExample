
import Foundation
import UIKit

func isPhone() -> Bool {
    return UIDevice.current.userInterfaceIdiom == .phone
}

func isLandscape() -> Bool {
    return UIApplication.shared.statusBarOrientation.isLandscape
}

func isLargeScale() -> Bool {
    return SkinManager.shared.isLargeScale
}

struct Emotions {
    static let padSize = CGSize.init(width: 310, height: 100)
    static let insets = UIEdgeInsets.init(top: 12, left: 12, bottom: 15, right: 12)
}
