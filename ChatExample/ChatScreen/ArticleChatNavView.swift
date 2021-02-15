
import Foundation
import UIKit

private let kBackgroundColorStyle = ColorSchemeName.otherBackground
private let kSeparatorBackgroundColorStyle = ColorSchemeName.stroke
private let kTitleTextColorStyle = ColorSchemeName.font
private let kTitleTextFontStyle = FontStyleName.header5
private let kBackButtonMargins = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
private let kSubscribeButtonMargins = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
private let kBackButtonRightInset: CGFloat = 25
private let kButtonWidth: CGFloat = 40

protocol ChatNavInteractive: class {
    func onNavTitleTap()
}

extension ArticleChatNavView: Skinable {
    func applyColorScheme() {
        backgroundColor = UIColor.color(for: kBackgroundColorStyle)
        title.textColor = UIColor.color(for: kTitleTextColorStyle)
        bottomSeparator.backgroundColor = UIColor.color(for: kSeparatorBackgroundColorStyle)
        activityView.applyColorScheme()
        backButton.setImage(UIImage.schemeImage(for: "backButton"), for: .normal)
    }
}

class ArticleChatNavView: SeparatorView {

    let minNavbarHeight: CGFloat = 44
    let maxNavbarHeight: CGFloat = 96

    weak var interactiveDelegate: ChatNavInteractive?

    private (set) var backButton: UIButton = {
        let back = UIButton(type: .custom)
        back.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: kBackButtonRightInset)
        back.setImage(UIImage.schemeImage(for: "backButton"), for: .normal)
        return back
    }()

    private (set) var rightButton: UIButton = {
        let right = UIButton(type: .custom)
        right.isHidden = true
        right.isUserInteractionEnabled = false
        right.setImage(UIImage(named: "bellOnButton"), for: .normal)
        return right
    }()

    private (set) var title: UILabel = {
        let title = UILabel()
        title.numberOfLines = SkinManager.shared.isLargeScale ? 1 : 2
        title.textAlignment = .center
        return title
    }()

    private (set) var activityView: ArticleChatActivityView = {
        let view = ArticleChatActivityView()
        view.isHidden = true
        return view
    }()

    init(frame: CGRect) {
        super.init(bottomSeparator: true)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    internal override func setupView() {
        super.setupView()

        self.addSubview(backButton)
        self.addSubview(rightButton)

        title.font = UIFont.fontStyle(for: .header5).ratioFont
        title.textColor = UIColor.color(for: .font)

        self.addSubview(title)
        self.addSubview(activityView)

        backButton.snp.makeConstraints { (make) in
            make.left.equalTo(self).offset(kBackButtonMargins.left)
            make.centerY.equalTo(self)
            make.width.equalTo(kButtonWidth)
            make.height.equalToSuperview()
        }

        rightButton.snp.makeConstraints { (make) in
            make.right.equalTo(self).offset(-kSubscribeButtonMargins.right)
            make.centerY.equalTo(self)
            make.width.equalTo(kButtonWidth)
        }

        title.snp.makeConstraints { (make) in
            make.center.equalTo(self)
            make.left.equalTo(backButton.snp.right).offset(kBackButtonMargins.right)
            make.right.equalTo(rightButton.snp.left).offset(-kSubscribeButtonMargins.left)
        }

        title.setContentHuggingPriority(.defaultLow, for: .horizontal)

        activityView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }

        title.font = UIFont.fontStyle(for: kTitleTextFontStyle).ratioFont

        title.isUserInteractionEnabled = true
        let gesture = UITapGestureRecognizer(target: self, action: #selector(titlePressed))
        title.addGestureRecognizer(gesture)

        applyColorScheme()
    }

    @objc private func titlePressed() {
        interactiveDelegate?.onNavTitleTap()
    }

    func showActivityView(state: ArticleChatActivityView.ActivityState) {
        activityView.setupView(state: state)
        activityView.isHidden = false
        activityView.activityIndicator.startAnimating()
        title.isHidden = true
    }

    func hideActivityView() {
        activityView.isHidden = true
        activityView.activityIndicator.stopAnimating()
        title.isHidden = false
    }

    func hideSeparator() {
        if bottomSeparator.isHidden { return }
        bottomSeparator.isHidden = true
    }

    func showSeparator() {
        if !bottomSeparator.isHidden { return }
        bottomSeparator.isHidden = false
    }
}

extension ArticleChatNavView: ArticleChatScreenAppearanceUpdate {
    func updateAppearance() {
        title.numberOfLines = SkinManager.shared.isLargeScale ? 1 : 2
        title.font = UIFont.fontStyle(for: .header5).ratioFont
        activityView.updateAppearance()
    }
}
