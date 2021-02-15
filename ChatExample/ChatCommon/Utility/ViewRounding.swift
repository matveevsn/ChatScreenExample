
import Foundation
import UIKit

extension UIView {
    func roundedRect(_ rect: CGRect, byRoundingCorners corners: UIRectCorner, cornerRadius radius: CGSize ) {
        let pathWithRadius = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: radius)
        let maskLayer = CAShapeLayer()
        maskLayer.path = pathWithRadius.cgPath
        layer.mask = maskLayer
    }

    func roundedRect(_ rect: CGRect, byRoundingCorners corners: UIRectCorner) {
        roundedRect(rect, byRoundingCorners: corners, cornerRadius: CGSize.init(width: 10, height: 10))
    }

    func roundedRect() {
        roundedRect(bounds, byRoundingCorners: .allCorners)
    }

    func border(withWidth width: CGFloat, color bColor: UIColor, cornerRadius radius: CGSize) {
        let maskPath = UIBezierPath(roundedRect: bounds, byRoundingCorners: .allCorners, cornerRadii: radius).cgPath

        let borderLayer = CAShapeLayer()
        borderLayer.path = maskPath
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.strokeColor = bColor.cgColor
        borderLayer.lineWidth = width
        borderLayer.frame = bounds
        if let shapeLayer = layer.sublayers?.last as? CAShapeLayer {
            shapeLayer.path = maskPath
        } else {
            layer.addSublayer(borderLayer)
        }
    }
}
