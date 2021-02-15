
import Foundation
import SnapKit
import UIKit

enum AppearanceType: Int {
    case single = 0
    case top
    case middle
    case bottom
}

enum ActionType: Int {
    case regular = 0
    case cancel
}

struct ActionItemModel {
    let title: String
    var appearanceType: AppearanceType
    let actionType: ActionType
    var handler: (() -> Void)?
}

class CustomActionSheetView: UIView {

    private let kCellIdentifier = "action-sheet-cell"

    private (set) var buttonsTable: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.estimatedRowHeight = 0
        tableView.estimatedSectionFooterHeight = 0
        tableView.estimatedSectionHeaderHeight = 0
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        tableView.isUserInteractionEnabled = true
        return tableView
    }()

    var actionItemModelList: [ActionItemModel]?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        self.backgroundColor = .clear
        buttonsTable.dataSource = self
        buttonsTable.delegate = self
        self.addSubview(buttonsTable)

        buttonsTable.register(CustomActionSheetCell.self, forCellReuseIdentifier: kCellIdentifier)

        buttonsTable.snp.makeConstraints { (make) in
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom)
            } else {
                make.bottom.equalTo(self)
            }
            make.left.equalTo(self)
            make.right.equalTo(self)
            make.height.equalTo(0)
        }
    }

    func setupView(model: [ActionItemModel]) {
        self.actionItemModelList = model
        let tableHeight = CustomActionSheetView.calculateHeight(models: model)
        self.buttonsTable.snp.updateConstraints { (make) in
            make.height.equalTo(tableHeight)
        }
    }

    static func calculateHeight(models: [ActionItemModel]) -> CGFloat {
        var height: CGFloat = 0
        models.forEach { (actionItem) in
            height += CustomActionSheetCell.calculateCellHeight(model: actionItem)
        }
        return height
    }
}

extension CustomActionSheetView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.actionItemModelList?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: kCellIdentifier) as? CustomActionSheetCell else { return UITableViewCell() }
        cell.configure(model: self.actionItemModelList![indexPath.row])
        return cell
    }
}

extension CustomActionSheetView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CustomActionSheetCell.calculateCellHeight(model: self.actionItemModelList![indexPath.row])
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let action = self.actionItemModelList?[indexPath.row] {
            action.handler?()
        }
    }
}
