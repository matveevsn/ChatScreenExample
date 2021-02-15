
import Foundation
import UIKit

protocol RecursiveLayout where Self: UIView {
    func setNeedsLayoutRecursive()
    func layoutIfNeedRecursive()
}

extension RecursiveLayout {

    func setNeedsLayoutRecursive() {
        self.setNeedsLayout()
    }

    func layoutIfNeedRecursive() {
        self.layoutIfNeeded()
    }

}
