
import Foundation
import UIKit

protocol ChatItemDelegate: class {
}

protocol ArticleChatConfigurable where Self: UITableViewCell {
    func configure(chatItem: ChatItem, chatItemDelegate: ChatItemDelegate?)
    static func calculateCellHeight(chatItem: ChatItem, width: CGFloat) -> CGFloat
}
