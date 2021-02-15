
import Foundation
import UIKit

extension ArticleChatListView: CommentDelegate {
    func onRate(point: CGPoint) {
        let pointInTableView = tableView.convert(point, from: nil)
        if let indexPath = tableView.indexPathForRow(at: pointInTableView) {
            interactiveDelegate?.onRate(indexPath: indexPath, point: point)
        }
    }

    func onQuoteTap(point: CGPoint) {
        let pointInTableView = tableView.convert(point, from: nil)
        if let indexPath = tableView.indexPathForRow(at: pointInTableView) {
            interactiveDelegate?.onCommentMessageQuoteTap(indexPath: indexPath)
        }
    }

    func onMessageLongPress(point: CGPoint) {
        let pointInTableView = tableView.convert(point, from: nil)
        if let indexPath = tableView.indexPathForRow(at: pointInTableView) {
            interactiveDelegate?.onCommentMessageLongTap(indexPath: indexPath)
        }
    }
}
