
import Foundation
import UIKit

extension ArticleChatListView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        assert(indexPath.section == 0 && indexPath.row < comments.count)

        if let configurableClass = type(of: self).classForItemList()[comments[indexPath.row].type] as? ArticleChatConfigurable.Type {
            let height = configurableClass.calculateCellHeight(chatItem: comments[indexPath.row], width: self.tableView.frame.width)
            self.commentsHeights[indexPath] = height
            return height
        }

        return 0
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //print("reloadView offset:\(scrollView.contentOffset.y)")
        var indexesToShow = [IndexPath]()
        self.unreadedOrigins.forEach { (arg0) in
            let (rect, index) = arg0
            if rect.maxY > scrollView.contentOffset.y && rect.origin.y < tableView.contentOffset.y + tableView.frame.height {
                indexesToShow.append(index)
            }
        }

        interactiveDelegate?.onScroll(
            redLine: checkRedLine(),
            unreadedIndexes: indexesToShow.count > 0 ? indexesToShow : nil
        )

        interactiveDelegate?.onScroll(isScrollOnTop: scrollView.contentOffset.y <= 0)
    }

    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        handleFlash()
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        handleFlash()
    }

    private func handleFlash() {
        if let index = indexForFlash {
            flashCell(indexPath: index)
            indexForFlash = nil
        }
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if #available(iOS 11.0, *) {
            return (interactiveDelegate?.isSwipeEnabled() ?? false && (tableView.cellForRow(at: indexPath) as? Swipeable) != nil)
        }

        return false
    }

    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        let action = UIContextualAction(style: .normal, title: nil) { [weak self] (_, _, handler) in
            self?.interactiveDelegate?.onSwipe(indexPath: indexPath)
            handler(true)
        }

        action.backgroundColor = UIColor.color(for: .otherBackground)

        if let cell = tableView.cellForRow(at: indexPath),
           let swipeableCell = tableView.cellForRow(at: indexPath) as? Swipeable {
            let likeOrigin = swipeableCell.likeButtonOrigin()
            if let replyImage = UIImage(named: "replyIco") {
                var imageHeight = cell.bounds.height
                if #available(iOS 14, *) {
                    imageHeight = 2*(likeOrigin.y + replyImage.size.height - cell.bounds.height/2)
                }

                action.image = UIGraphicsImageRenderer(size: CGSize(width: replyImage.size.width, height: imageHeight)).image { (context) in
                    var replyImageYPos = likeOrigin.y
                    if #available(iOS 14, *) {
                        replyImageYPos = context.format.bounds.size.height - replyImage.size.height
                    }

                    replyImage.draw(in: CGRect(x: 0, y: replyImageYPos, width: replyImage.size.width, height: replyImage.size.height))
                }
            }
        }

        let configuration = UISwipeActionsConfiguration(actions: [action])
        configuration.performsFirstActionWithFullSwipe = true
        return configuration
    }
}
