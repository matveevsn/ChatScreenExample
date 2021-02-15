
import Foundation
import UIKit

private let kCounterViewWidth: CGFloat = isPhone() ? 36 : 45
private let kCounterViewHeight: CGFloat = isPhone() ? 36 : 45
private let kSpaceBetweenArrowAndCounter: CGFloat = isPhone() ? 4 : 5

private let kCounterBackgroundColorStyle = ColorSchemeName.myMessage
private let kCounterTextColorStyle = ColorSchemeName.onSurfaceFont
private let kUnreadedCountLabelStyle = ColorSchemeName.primary

private let kCounterCornerRadius: CGFloat = 18
private let kCounterOpacity: Float = 0.9
private let kCounterLabelFontStyle = FontStyleName.paragraph2Reg
private let kCounterValueTransitionDuration: CFTimeInterval = 0.25
private let kAppearanceAnimationDuration = 0.2

protocol UnreadViewDelegate: class {
    func onBottomButton()
}

class ArticleChatUnreadView: UIView {

    var unreadedCount: Int?
    weak var unreadDelegate: UnreadViewDelegate?

    private (set) var bottomButtonView: UIImageView = {
        let bottomButton = UIImageView(image: UIImage(named: "bottomButton"))
        bottomButton.isHidden = true
        return bottomButton
    }()

    private (set) var bottomArrowView: UIImageView = {
        let bottomButton = UIImageView(image: UIImage(named: "bottomArrow"))
        bottomButton.isHidden = true
        return bottomButton
    }()

    private (set) var unreadedCountLabel: UILabel = {
        let label = UILabel()
        label.isHidden = true
        label.isUserInteractionEnabled = true
        label.layer.opacity = kCounterOpacity
        label.textAlignment = .center
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        unreadedCountLabel.font = UIFont.fontStyle(for: kCounterLabelFontStyle).font
        self.addSubview(unreadedCountLabel)
        self.addSubview(bottomButtonView)
        self.addSubview(bottomArrowView)

        unreadedCountLabel.font = UIFont.fontStyle(for: kCounterLabelFontStyle).font

        unreadedCountLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.width.equalTo(kCounterViewWidth)
            make.height.equalTo(kCounterViewHeight)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }

        bottomButtonView.snp.makeConstraints { (make) in
            make.center.equalTo(unreadedCountLabel)
        }

        bottomArrowView.snp.makeConstraints { (make) in
            make.top.equalTo(unreadedCountLabel.snp.bottom).offset(kSpaceBetweenArrowAndCounter)
            make.bottom.equalToSuperview()
            make.centerX.equalTo(unreadedCountLabel)
        }

        bottomButtonView.setContentCompressionResistancePriority(.required, for: .horizontal)

        let tapRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(onBottomButton))
        self.addGestureRecognizer(tapRecognizer)

        applyColorScheme()
    }

    @objc func onBottomButton() {
        unreadDelegate?.onBottomButton()
    }

    func setupView(unreadedCount: Int, animated: Bool = false) {
        self.unreadedCount = unreadedCount
        self.unreadedCountLabel.isHidden = !(unreadedCount > 0)
        self.bottomButtonView.isHidden = unreadedCount > 0
        self.bottomArrowView.isHidden = !(unreadedCount > 0)

        if animated {
            addTransitionAnimation()
        }

        self.unreadedCountLabel.text = String(unreadedCount)
    }

    private func addTransitionAnimation() {
        let animation = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animation.type = .fade
        animation.duration = kCounterValueTransitionDuration
        self.unreadedCountLabel.layer.add(animation, forKey: "kCATransitionFade")
    }

    func show() {
        if !self.isHidden {
            return
        }
        self.isHidden = false
        self.layer.opacity = 0
        UIView.animate(withDuration: kAppearanceAnimationDuration, animations: {
            self.layer.opacity = 1
        }, completion: { (_) in
        })
    }

    func hide() {
        if self.isHidden {
            return
        }
        self.layer.opacity = 1
        UIView.animate(withDuration: kAppearanceAnimationDuration, animations: {
            self.layer.opacity = 0
        }, completion: { (_) in
            self.isHidden = true
        })
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        unreadedCountLabel.roundedRect(unreadedCountLabel.bounds, byRoundingCorners: .allCorners, cornerRadius: CGSize(width: kCounterCornerRadius, height: kCounterCornerRadius))
    }
}

extension ArticleChatUnreadView: Skinable {
    func applyColorScheme() {
        bottomButtonView.image = UIImage.schemeImage(for: "bottomButton")
        bottomArrowView.image = UIImage.schemeImage(for: "bottomArrow")
        unreadedCountLabel.backgroundColor = UIColor.color(for: kUnreadedCountLabelStyle)
        unreadedCountLabel.textColor = UIColor.color(for: kCounterTextColorStyle)

        unreadedCountLabel.backgroundColor = UIColor.color(for: kCounterBackgroundColorStyle)
        unreadedCountLabel.textColor = UIColor.color(for: kCounterTextColorStyle)
    }
}
