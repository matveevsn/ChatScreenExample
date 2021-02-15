
import Foundation
import UIKit

extension ArticleChatController {
    @objc func dismissKeyboard() {
        _ = self.sendView.dismissKeyboardIfNeed()
    }

    @objc func keyboardNotification(notification: NSNotification) {

        if let startFrame = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue,
            let endFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            !startFrame.equalTo(endFrame) {

            if #available(iOS 13.0, *), !isPhone() && endFrame.width != sendView.bounds.width {
                return
            }

            var correctedOffset: CGFloat = 0
            if endFrame.origin.y >= UIScreen.main.bounds.size.height {
                correctedOffset = -offsetWithRespectToSafeArea(frame: startFrame)
                self.sendViewBottomConstraint?.update(offset: 0)
            } else {
                correctedOffset = offsetWithRespectToSafeArea(frame: endFrame)
                self.sendViewBottomConstraint?.update(offset: -correctedOffset)
            }

            let duration: TimeInterval = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animation = UIView.AnimationOptions(
                rawValue: (notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber)?.uintValue ?? UIView.AnimationOptions.curveEaseInOut.rawValue
            )

            UIView.animate(
                withDuration: duration,
                delay: TimeInterval(0),
                options: animation,
                animations: {
                    self.chatListView.tableView.contentOffset = CGPoint(
                        x: self.chatListView.tableView.contentOffset.x,
                        y: self.chatListView.tableView.contentOffset.y + correctedOffset
                    )
                    self.view.layoutIfNeeded()
                    self.chatListView.updateContentInset()
                },
                completion: nil
            )
        }
    }

    private func offsetWithRespectToSafeArea(frame: CGRect) -> CGFloat {
        var correctedOffset: CGFloat = 0
        if #available(iOS 11.0, *) {
            correctedOffset = frame.height - self.view.safeAreaInsets.bottom
        } else {
            correctedOffset = frame.height
        }
        return correctedOffset
    }
}
