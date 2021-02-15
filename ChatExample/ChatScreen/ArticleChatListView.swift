
import Foundation
import UIKit

private let backgroundColorStyle = ColorSchemeName.otherBackground
private let likeButtonTintColorStyle = ColorSchemeName.purpleGray

private let kRedLineForBottomInsertion: CGFloat = 5

protocol ArticleChatInteractive: class {
    func onCommentMessageLongTap(indexPath: IndexPath)
    func onCommentMessageQuoteTap(indexPath: IndexPath)
    func onRate(indexPath: IndexPath, point: CGPoint)
    func onSwipe(indexPath: IndexPath)
    func onScroll(redLine: Bool, unreadedIndexes: [IndexPath]?)
    func onScroll(isScrollOnTop: Bool)
    func shouldUpdatePosition() -> Bool
    func isSwipeEnabled() -> Bool
}

let classForItem: [ChatItemType: AnyClass] = [
    ChatItemType.comment: ArticleChatCommentCell.self,
    ChatItemType.unread: ArticleChatUnreadCell.self,
    ChatItemType.complained: ArticleChatCommentComplainedCell.self
]

class ArticleChatListView: UIView {

    private let kCellIdentifier = "chat-cell-identifier"

    weak var tableView: UITableView!
    weak var interactiveDelegate: ArticleChatInteractive?
    private (set) var comments: Array = [ChatItem]()
    var commentsHeights = [IndexPath: CGFloat]()
    private (set) var unreadedOrigins = [(CGRect, IndexPath)]()
    var indexForFlash: IndexPath?
    var scrollOffset: CGFloat = 0

    override init(frame: CGRect) {
        super.init(frame: frame)

        let tableView = UITableView(frame: .zero)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 0
        tableView.estimatedSectionFooterHeight = 0
        tableView.estimatedSectionHeaderHeight = 0
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        self.addSubview(tableView)
        self.tableView = tableView

        if #available( iOS 11.0, * ) {
           self.tableView.contentInsetAdjustmentBehavior = .never
        }

        type(of: self).classForItemList().forEach { (type, classType) in
            tableView.register(classType, forCellReuseIdentifier: type.rawValue)
        }

        tableView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }

        applyColorScheme()
    }

    class func classForItemList() -> [ChatItemType: AnyClass] {
        return classForItem
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func reloadView() {
        self.tableView.reloadData()
    }

    func reloadView(comments: [ChatItem], indexToScroll: IndexPath?) {
        print("reloadView comments count: \(comments.count)")
        calculateHeights(data: comments, width: self.tableView.frame.width) { (calculatedHeights) in
            self.comments = comments
            self.commentsHeights = calculatedHeights
            self.tableView.reloadData()
            self.changeContentInsetTop(totalContentHeight: calculatedHeights.values.reduce(0, +))

            DispatchQueue.main.async {
                if self.comments.count > 0 {
                    if let index = indexToScroll {
                        self.tableView.scrollToRow(at: index, at: .bottom, animated: false)
                    } else {
                        let bottomIndex = IndexPath(row: self.comments.count - 1, section: 0)
                        self.tableView.scrollToRow(at: bottomIndex, at: .bottom, animated: false)
                    }
                }
            }
        }
    }

    func updateUnreadedOrigins(unreadedIndexList: [IndexPath]?) {
        if let unreadedOrigins = self.calculateUnreadedOrigins(unreadedIndexList: unreadedIndexList) {
            self.unreadedOrigins = unreadedOrigins
        }
    }

    private func calculateUnreadedOrigins(unreadedIndexList: [IndexPath]?) -> [(CGRect, IndexPath)]? {
        guard let unreadedList = unreadedIndexList else { return nil }
        var unreadedOrigins = [(CGRect, IndexPath)]()
        unreadedList.forEach { (indexPath) in
            let rectForRow = self.tableView.rectForRow(at: indexPath)
            if rectForRow != .zero {
                unreadedOrigins.append((rectForRow, indexPath))
            }
        }
        return unreadedOrigins
    }

    private func calculateHeights(data: [ChatItem], width: CGFloat, completion: @escaping ([IndexPath: CGFloat]) -> Void) {
        DispatchQueue.global().async {
            let methodStart = Date()

            let cachedHeights = type(of: self).calculateHeightsIndex(data: data, width: width)

            let methodFinish = Date()
            let executionTime = methodFinish.timeIntervalSince(methodStart)
            print("calculateCellHeight Total Execution time: \(executionTime)")

            DispatchQueue.main.async {
                completion(cachedHeights)
            }
        }
    }

    class func calculateHeightsIndex(data: [ChatItem], width: CGFloat) -> [IndexPath: CGFloat] {
        var heightsIndex = [IndexPath: CGFloat]()
        data.enumerated().forEach { (offset, element) in
            if let configurableClass = classForItemList()[element.type] as? ArticleChatConfigurable.Type {
                heightsIndex[IndexPath(row: offset, section: 0)] = configurableClass.calculateCellHeight(chatItem: element, width: width)
            }
        }
        return heightsIndex
    }

    func insertItem(item: ChatItem, indexPath: IndexPath, unreadedList: [IndexPath]?, scrollToBottom: Bool) {
        let needToScroll = scrollToBottom || (checkRedLine() && interactiveDelegate?.shouldUpdatePosition() ?? true)
        self.comments.append(item)

        self.calculateHeights(data: self.comments, width: self.bounds.width) { (heightsIndex) in
            self.changeContentInsetTop(totalContentHeight: heightsIndex.values.reduce(0, +))

            self.tableView.insertRows(at: [indexPath], with: .bottom)
            if needToScroll {
                let indexPathToScroll = IndexPath(row: self.comments.count - 1, section: 0)
                self.tableView.scrollToRow(at: indexPathToScroll, at: .bottom, animated: true)
            }

            DispatchQueue.main.async {
                if let unreadedOriginsList = self.calculateUnreadedOrigins(unreadedIndexList: unreadedList) {
                    self.unreadedOrigins = unreadedOriginsList
                    self.scrollViewDidScroll(self.tableView)
                }
            }
        }
    }

    func moveItem(fromPath: IndexPath, toPath: IndexPath) {
        if fromPath.row < self.comments.count {
            let comment = self.comments[fromPath.row]
            self.comments.remove(at: fromPath.row)
            self.comments.append(comment)
            tableView.moveRow(at: fromPath, to: toPath)
        }
    }

    func updateItem(item: ChatItem, indexPath: IndexPath) {
        assert(indexPath.row < self.comments.count)
        if indexPath.row < self.comments.count {
            self.comments[indexPath.row] = item
            guard let cell = tableView.cellForRow(at: indexPath) as? ArticleChatConfigurable else { return }
            cell.configure(chatItem: item, chatItemDelegate: self)

            if let recursiveLayout = cell as? RecursiveLayout {
                recursiveLayout.setNeedsLayoutRecursive()
                recursiveLayout.layoutIfNeedRecursive()
            } else {
                cell.setNeedsLayout()
                cell.layoutIfNeeded()
            }
        }
    }

    func reloadItem(item: ChatItem, indexPath: IndexPath) {
        assert(indexPath.row < self.comments.count)
        if indexPath.row < self.comments.count {
            self.comments[indexPath.row] = item
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }

    func deleteItem(indexPath: IndexPath, unreadedList: [IndexPath]?) {
        assert(indexPath.row < self.comments.count)
        self.comments.remove(at: indexPath.row)
        self.commentsHeights = self.commentsHeights.filter({ (arg0) -> Bool in
            let (key, _) = arg0
            return key.row < indexPath.row
        })

        self.calculateHeights(data: self.comments, width: self.bounds.width) { (heightsIndex) in
            self.changeContentInsetTop(totalContentHeight: heightsIndex.values.reduce(0, +))

            self.tableView.deleteRows(at: [indexPath], with: .middle)

            DispatchQueue.main.async {
                if let unreadedOriginsList = self.calculateUnreadedOrigins(unreadedIndexList: unreadedList) {
                    self.unreadedOrigins = unreadedOriginsList
                    self.scrollViewDidScroll(self.tableView)
                }
            }
        }
    }

    func updateContentInset() {
        let heightsIndex = type(of: self).calculateHeightsIndex(data: self.comments, width: self.bounds.width)
        changeContentInsetTop(totalContentHeight: heightsIndex.values.reduce(0, +))
    }

    private func changeContentInsetTop(totalContentHeight: CGFloat) {
        if totalContentHeight > 0 && totalContentHeight < self.tableView.bounds.height {
            var tableInset = self.tableView.contentInset
            tableInset.top = self.tableView.bounds.height - totalContentHeight
            self.tableView.contentInset = tableInset
        } else {
            var tableInset = self.tableView.contentInset
            tableInset.top = 0
            self.tableView.contentInset = tableInset
        }
    }

    func checkRedLine() -> Bool {
        return tableView.contentOffset.y + tableView.contentInset.top + tableView.frame.height > tableView.contentSize.height - kRedLineForBottomInsertion
    }

    func shadowCellAtPoint(point: CGPoint) {
        if let indexPath = tableView.indexPathForRow(at: point) {
            if let cell = tableView.cellForRow(at: indexPath) as? ArticleChatCommentCell {
                cell.enableShadow(enabled: true)
            }
        }
    }

    func shadowCell(indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? ArticleChatCommentCell {
            cell.enableShadow(enabled: true)
        }
    }

    func clearShadow() {
        for cell in tableView.visibleCells {
            if let chatCell = cell as? ArticleChatCommentCell {
                chatCell.enableShadow(enabled: false)
            }
        }
    }

    func scrollToBottom(animated: Bool) {
        if self.comments.count > 0 {
            let bottomIndex = IndexPath(row: self.comments.count - 1, section: 0)
            self.tableView.scrollToRow(at: bottomIndex, at: .bottom, animated: animated)
        }
    }

    func scrollTo(indexPath: IndexPath, animated: Bool) {
        self.tableView.scrollToRow(at: indexPath, at: .middle, animated: animated)
    }

    func scrollToWithFlash(indexPath: IndexPath, animated: Bool) {
        self.tableView.scrollToRow(at: indexPath, at: .middle, animated: animated)
        if !animated {
            flashCell(indexPath: indexPath)
        } else {
            self.indexForFlash = indexPath
        }
    }

    func rateIfNeed(point: CGPoint) -> Bool {
        let pointInTableView = tableView.convert(point, from: nil)
        let view = self.tableView.hitTest(pointInTableView, with: nil)
        if let rateButton = view as? UIButton {
            rateButton.sendActions(for: .touchUpInside)
            return true
        }
        return false
    }

    func flashCell(indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? ArticleChatCommentCell {
            cell.flash()
        }
    }
}

extension ArticleChatListView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.comments.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        assert(indexPath.section == 0 && indexPath.row < comments.count)
        guard let cell = tableView.dequeueReusableCell(withIdentifier: comments[indexPath.row].type.rawValue) as? ArticleChatConfigurable else { return UITableViewCell() }
        cell.configure(chatItem: comments[indexPath.row], chatItemDelegate: self)
        return cell
    }
}

extension ArticleChatListView: Skinable {
    func applyColorScheme() {
        tableView.backgroundColor = UIColor.color(for: backgroundColorStyle)
        if #available(iOS 9.0, *) {
            UIImageView.appearance(whenContainedInInstancesOf: [ArticleChatListView.self]).tintColor = UIColor.color(for: likeButtonTintColorStyle)
        }

        tableView.reloadData()
    }
}
