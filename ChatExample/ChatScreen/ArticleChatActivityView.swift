
import Foundation
import UIKit

private let kProgressRightMargin: CGFloat = 5
private let kFontStyleName = FontStyleName.header5

class ArticleChatActivityView: UIView {

    enum ActivityState: Int {
        case refreshing = 0
        case connecting
    }

    private (set) var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.preferStyle)
        activityIndicator.hidesWhenStopped = true
        return activityIndicator
    }()

    private (set) var activityTitle: UILabel = {
        let title = UILabel()
        title.numberOfLines = 1
        title.font = UIFont.fontStyle(for: kFontStyleName).ratioFont
        title.textAlignment = .center
        title.text = NSLocalizedString("article_chat_activity_title", comment: "")
        return title
    }()

    private var state: ActivityState = .refreshing

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {

        self.backgroundColor = .clear

        self.addSubview(activityIndicator)
        self.addSubview(activityTitle)

        activityIndicator.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview()
        }

        activityTitle.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(activityIndicator.snp.right).offset(kProgressRightMargin)
            make.right.equalToSuperview()
        }

        applyColorScheme()
    }

    func setupView(state: ActivityState) {
        self.state = state

        if state == .refreshing {
            activityTitle.text = NSLocalizedString("article_chat_activity_title", comment: "")
        } else if state == .connecting {
            activityTitle.text = NSLocalizedString("article_chat_connecting_title", comment: "")
        }
    }

    func updateAppearance() {
        activityTitle.font = UIFont.fontStyle(for: kFontStyleName).ratioFont
    }
}

extension ArticleChatActivityView: Skinable {
    func applyColorScheme() {
        activityTitle.textColor = UIColor.color(for: .font)
        activityIndicator.style = UIActivityIndicatorView.preferStyle
    }
}
