
import Foundation
import UIKit

private let titleFont = UIFont.fontStyle(for: .header2Reg).font
private let titleCancelFont = UIFont.fontStyle(for: .header2).font
private let titleHighlightedBackgroundHexColor = 0xC6C6D6

private let titleColorStyleName = ColorSchemeName.primary
private let buttonsBackgroundColorStyleName = ColorSchemeName.otherMessage
private let bottomDelimeterColorStyleName = ColorSchemeName.chatReport

private let titleLableTopInsets = isPhone() ? UIEdgeInsets(top: 3, left: 10, bottom: 1, right: 10) : UIEdgeInsets(top: 3, left: 234, bottom: 1, right: 234)
private let titleLableMiddleInsets = isPhone() ? UIEdgeInsets(top: 0, left: 10, bottom: 1, right: 10) : UIEdgeInsets(top: 0, left: 234, bottom: 1, right: 234)
private let titleLableBottomInsets = isPhone() ? UIEdgeInsets(top: 0, left: 10, bottom: 10, right: 10) : UIEdgeInsets(top: 0, left: 234, bottom: 10, right: 234)
private let titleSingleLableInsets = isPhone() ? UIEdgeInsets(top: 0, left: 10, bottom: 10, right: 10) : UIEdgeInsets(top: 0, left: 234, bottom: 10, right: 234)

private let titleCornerRadius = CGSize(width: 10, height: 10)
private let customActionSheetCellHeight: CGFloat = 58

class CustomActionSheetCell: UITableViewCell {

    private var actionItemModel: ActionItemModel?

    private (set) var buttonLabel: UILabel = {
        let buttonLabel = UILabel()
        buttonLabel.textColor = UIColor.color(for: titleColorStyleName)
        buttonLabel.backgroundColor = UIColor.color(for: buttonsBackgroundColorStyleName)
        buttonLabel.textAlignment = .center
        return buttonLabel
    }()

    private (set) var buttonShadow: UIView = {
        let messageShadow = UIView()
        messageShadow.backgroundColor = .clear
        messageShadow.layer.shadowColor = UIColor.black.cgColor
        messageShadow.layer.shadowOpacity = 0.25
        messageShadow.layer.shadowOffset = .zero
        messageShadow.layer.shadowRadius = 2
        return messageShadow
    }()

    private (set) var bottomDelimeter: UIView = {
        let bottomDelimeter = UIView()
        bottomDelimeter.backgroundColor = UIColor.color(for: bottomDelimeterColorStyleName)
        return bottomDelimeter
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
        self.contentView.backgroundColor = .clear
        self.backgroundColor = .clear
        self.contentView.addSubview(buttonShadow)
        self.contentView.addSubview(buttonLabel)
        self.contentView.addSubview(bottomDelimeter)
    }

    public func configure(model: ActionItemModel) {
        actionItemModel = model
        buttonLabel.text = self.actionItemModel?.title
        buttonLabel.font = fontForType(type: self.actionItemModel?.actionType)
        buttonLabel.backgroundColor = backgroundColorForType(type: self.actionItemModel?.actionType)
        bottomDelimeter.isHidden = !delimeterForAppearanceType(type: self.actionItemModel?.appearanceType)
    }

    private func backgroundColorForType(type: ActionType?) -> UIColor {
        guard let actionType = type else { return UIColor.color(for: buttonsBackgroundColorStyleName) }
        if actionType == .regular {
            return UIColor.color(for: buttonsBackgroundColorStyleName)
        } else if actionType == .cancel {
            return UIColor.color(for: buttonsBackgroundColorStyleName)
        }
        return UIColor.color(for: buttonsBackgroundColorStyleName)
    }

    private func fontForType(type: ActionType?) -> UIFont {
        guard let actionType = type else { return titleFont }
        if actionType == .regular {
            return titleFont
        } else if actionType == .cancel {
            return titleCancelFont
        }
        return titleFont
    }

    private func delimeterForAppearanceType(type: AppearanceType?) -> Bool {
        guard let appearanceType = type else { return true }
        if appearanceType == .top {
            return true
        } else if appearanceType == .middle {
            return true
        }
        return false
    }

    static private func insetsForType(type: AppearanceType?) -> UIEdgeInsets {
        guard let appeareanceType = type else { return UIEdgeInsets() }
        if appeareanceType == .bottom {
            return titleLableBottomInsets
        } else if appeareanceType == .middle {
            return titleLableMiddleInsets
        } else if appeareanceType == .top {
            return titleLableTopInsets
        } else if appeareanceType == .single {
            return titleSingleLableInsets
        }
        return UIEdgeInsets()
    }

    static func calculateCellHeight(model: ActionItemModel) -> CGFloat {
        let insets = insetsForType(type: model.appearanceType)
        return insets.top + customActionSheetCellHeight + insets.bottom
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        buttonLabel.frame = self.contentView.frame.inset(by: CustomActionSheetCell.insetsForType(type: self.actionItemModel?.appearanceType))
        buttonLabel.roundedRect(buttonLabel.bounds, byRoundingCorners: cornerRadius(), cornerRadius: titleCornerRadius)
        bottomDelimeter.frame = CGRect(x: buttonLabel.frame.origin.x, y: buttonLabel.frame.maxY, width: buttonLabel.frame.size.width, height: 1)
        buttonShadow.frame = buttonLabel.frame
        buttonShadow.layer.shadowPath = UIBezierPath(roundedRect: buttonShadow.bounds, byRoundingCorners: cornerRadius(), cornerRadii: titleCornerRadius).cgPath
    }

    private func cornerRadius() -> UIRectCorner {
        guard let model = actionItemModel else { return .allCorners }

        if model.appearanceType == AppearanceType.single {
            return .allCorners
        } else if model.appearanceType == AppearanceType.top {
            return [.topLeft, .topRight]
        } else if model.appearanceType == AppearanceType.middle {
            return []
        } else if model.appearanceType == AppearanceType.bottom {
            return [.bottomLeft, .bottomRight]
        }
        return .allCorners
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        buttonLabel.backgroundColor = highlighted ? UIColor(rgb: titleHighlightedBackgroundHexColor) : backgroundColorForType(type: actionItemModel?.actionType)
    }
}
