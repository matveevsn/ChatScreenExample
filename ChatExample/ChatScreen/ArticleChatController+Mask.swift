
import Foundation
import UIKit

extension ArticleChatController {

    func applyMask(indexPath: IndexPath, actionSheetHeight: CGFloat) {
        let (cellRectInSuperView, offset) = calculateMaskRect(indexPath: indexPath, actionSheetHeight: actionSheetHeight)
        let maskLayer = addMaskRect(maskRect: cellRectInSuperView)
        if offset > 0 {
            chatListView.tableView.contentInset = UIEdgeInsets(top: chatListView.tableView.contentInset.top, left: 0, bottom: actionSheetHeight + offset, right: 0)
            chatListView.scrollOffset = offset
            animateMaskRect(maskLayer: maskLayer, cellRectInSuperView: cellRectInSuperView, deltaOffset: offset, completion: nil)
        }
    }

    func unapplyMask(indexPath: IndexPath, offset: CGFloat, completion: (() -> Void)?) {
        let rectInTable = chatListView.tableView.rectForRow(at: indexPath)
        let cellRectInSuperView = chatListView.tableView.convert(rectInTable, to: self.view)
        let maskLayer = addMaskRect(maskRect: cellRectInSuperView)
        if offset > 0 {
            animateMaskRect(maskLayer: maskLayer, cellRectInSuperView: cellRectInSuperView, deltaOffset: -offset, completion: completion)
            chatListView.tableView.contentInset = UIEdgeInsets(top: chatListView.tableView.contentInset.top, left: 0, bottom: 0, right: 0)
            chatListView.scrollOffset = 0
        }
    }

    func calculateMaskRect(indexPath: IndexPath, actionSheetHeight: CGFloat) -> (CGRect, CGFloat) {

        let rectInTable = chatListView.tableView.rectForRow(at: indexPath)
        var cellRectInSuperView = chatListView.tableView.convert(rectInTable, to: self.view)

        var actionSheetPoint: CGPoint = .zero
        if #available(iOS 11.0, *) {
            actionSheetPoint = CGPoint(x: 0, y: self.view.bounds.height - actionSheetHeight - self.view.safeAreaInsets.bottom)
        } else {
            actionSheetPoint = CGPoint(x: 0, y: self.view.bounds.height - actionSheetHeight)
        }

        let actionSheetPointInTableView = chatListView.tableView.convert(actionSheetPoint, from: self.view)
        var deltaOffset: CGFloat = 0
        if cellRectInSuperView.maxY > actionSheetPoint.y && cellRectInSuperView.height < (actionSheetPointInTableView.y - chatListView.tableView.contentOffset.y) {
            deltaOffset = cellRectInSuperView.maxY - actionSheetPoint.y
        } else {
            let yOriginalPos = cellRectInSuperView.origin.y
            cellRectInSuperView.origin.y = max(cellRectInSuperView.origin.y, chatListView.frame.origin.y)
            cellRectInSuperView.size.height -= cellRectInSuperView.origin.y - yOriginalPos
            cellRectInSuperView.size.height -= cellRectInSuperView.maxY > chatListView.frame.maxY ? cellRectInSuperView.maxY - chatListView.frame.maxY : 0
        }

        return (cellRectInSuperView, deltaOffset)
    }

    func addMaskRect(maskRect: CGRect) -> CAShapeLayer {

        let path = UIBezierPath(rect: maskRect)
        path.append(UIBezierPath(rect: shadowView.bounds))
        path.usesEvenOddFillRule = true

        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        maskLayer.fillRule = CAShapeLayerFillRule.evenOdd
        shadowView.layer.mask = maskLayer
        return maskLayer
    }

    func animateMaskRect(maskLayer: CAShapeLayer, cellRectInSuperView: CGRect, deltaOffset: CGFloat, completion: (() -> Void)?) {

        let targetPath = UIBezierPath(rect: cellRectInSuperView.offsetBy(dx: 0, dy: -deltaOffset))
        targetPath.append(UIBezierPath(rect: shadowView.bounds))

        let anim = CABasicAnimation(keyPath: "path")
        anim.fromValue = maskLayer.path
        anim.toValue = targetPath.cgPath
        anim.duration = kLongPressAnimationDuration
        anim.fillMode = CAMediaTimingFillMode.forwards
        anim.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        maskLayer.add(anim, forKey: "animatePath")

        let tableViewBounds = chatListView.tableView.bounds
        let animation = CABasicAnimation(keyPath: "bounds")
        animation.duration = kLongPressAnimationDuration
        animation.fromValue = NSValue(cgRect: tableViewBounds)
        animation.toValue = NSValue(cgRect: tableViewBounds.offsetBy(dx: 0, dy: deltaOffset))
        animation.fillMode = CAMediaTimingFillMode.forwards
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        chatListView.tableView.layer.add(animation, forKey: "animateMove")

        CATransaction.begin()
        maskLayer.path = targetPath.cgPath
        chatListView.tableView.bounds = tableViewBounds.offsetBy(dx: 0, dy: deltaOffset)
        CATransaction.setCompletionBlock(completion)
        CATransaction.commit()
    }

    @objc func onShadowViewTap(recognizer: UITapGestureRecognizer) {
        if let indexPath = commentsList?.selectedIndex {
            hideShadowView(indexPath: indexPath, completion: nil)
        }
    }

    func showShadowView(indexPath: IndexPath, actionSheetHeight: CGFloat) {

        chatListView.shadowCell(indexPath: indexPath)
        applyMask(indexPath: indexPath, actionSheetHeight: actionSheetHeight)

        shadowView.isHidden = false
        shadowView.layer.opacity = 0
        UIView.animate(withDuration: kLongPressAnimationDuration, animations: {
            self.shadowView.layer.opacity = 0.5
        })
    }

    func hideShadowView(indexPath: IndexPath, completion: (() -> Void)?) {

        chatListView.clearShadow()
        if chatListView.scrollOffset > 0 {
            unapplyMask(indexPath: indexPath, offset: chatListView.scrollOffset, completion: nil)
        }

        shadowView.layer.opacity = 0.5
        UIView.animate(withDuration: kLongPressAnimationDuration, animations: {
            self.shadowView.layer.opacity = 0
        }, completion: { (_) in
            self.shadowView.isHidden = true
            completion?()
        })
    }

}
