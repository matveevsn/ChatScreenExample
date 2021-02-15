
import Foundation
import UIKit

private let kDelimeterHeight: CGFloat = 26
private let kDelimeterLineHeight: CGFloat = 2
private let kDelimeterPadding: CGFloat = isPhone() ? 10 : 20
private let kDelimeterVerticalMarginTop: CGFloat = isPhone() ? 25 : 36
private let kDelimeterVerticalMarginBottom: CGFloat = isPhone() ? 21 : 15

class ArticleChatUnreadCell: UITableViewCell, ArticleChatConfigurable {

    var model: ChatUread?

    private (set) var title: UILabel = {
        let title = UILabel()
        title.textAlignment = .center
        return title
    }()

    private (set) var leftDelimeter: UIView = {
        let leftDelimeter = UIView()
        return leftDelimeter
    }()

    private (set) var rightDelimeter: UIView = {
        let rightDelimeter = UIView()
        return rightDelimeter
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {

        self.contentView.backgroundColor = UIColor.color(for: .otherBackground)
        self.contentView.addSubview(title)
        self.contentView.addSubview(leftDelimeter)
        self.contentView.addSubview(rightDelimeter)

        title.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.contentView)
            make.centerY.equalTo(leftDelimeter)
        }

        leftDelimeter.snp.makeConstraints { (make) in
            make.left.equalTo(self.contentView).offset(kDelimeterPadding)
            make.right.equalTo(title.snp.left).offset(-kDelimeterPadding)
            make.top.equalTo(self.contentView).offset(kDelimeterVerticalMarginTop)
            make.height.equalTo(kDelimeterLineHeight)
        }

        rightDelimeter.snp.makeConstraints { (make) in
            make.right.equalTo(self.contentView).offset(-kDelimeterPadding)
            make.left.equalTo(title.snp.right).offset(kDelimeterPadding)
            make.top.equalTo(self.contentView).offset(kDelimeterVerticalMarginTop)
            make.height.equalTo(kDelimeterLineHeight)
        }

        title.font = UIFont.fontStyle(for: .paragraph2).ratioFont
        title.backgroundColor = UIColor.color(for: .otherBackground)
        title.textColor = UIColor.color(for: .primary)
        leftDelimeter.backgroundColor = UIColor.color(for: .primary)
        rightDelimeter.backgroundColor = UIColor.color(for: .primary)

    }

    func configure(chatItem: ChatItem, chatItemDelegate: ChatItemDelegate?) {
        guard let unreadItem = chatItem as? ChatUread else { return }
        self.model = unreadItem
        title.text = self.model?.title

        applyColorScheme()
        title.font = UIFont.fontStyle(for: .paragraph2).ratioFont
    }

    static func calculateCellHeight(chatItem: ChatItem, width: CGFloat) -> CGFloat {
        return kDelimeterLineHeight + kDelimeterVerticalMarginTop + kDelimeterVerticalMarginBottom
    }
}

extension ArticleChatUnreadCell: Skinable {
    func applyColorScheme() {
        self.contentView.backgroundColor = UIColor.color(for: .otherBackground)
        title.backgroundColor = UIColor.color(for: .otherBackground)
        title.textColor = UIColor.color(for: .primary)
        leftDelimeter.backgroundColor = UIColor.color(for: .primary)
        rightDelimeter.backgroundColor = UIColor.color(for: .primary)
    }
}
