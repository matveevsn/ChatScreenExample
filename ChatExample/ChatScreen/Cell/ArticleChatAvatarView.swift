
import Foundation
import UIKit

private let kAvatarImageViewSize: CGSize = CGSize(width: 26, height: 26)
private let kAvatarTopPadding: CGFloat = isPhone() ? 0 : 10
private let kAvatarCornerRadius: CGSize = CGSize(width: 10, height: 10)
private let kNickNameLeftPadding: CGFloat = 10

private let kNickNameTextFontStyle = FontStyleName.header5
private let kNickNameTextColorStyle = ColorSchemeName.font

class ArticleChatAvatarView: UIView {

    private (set) var authorAvatar: UIImageView = {
        let avatarImage = UIImageView()
        return avatarImage
    }()

    private (set) var authorNickname: UILabel = {
        let authorNickname = UILabel()
        return authorNickname
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        self.addSubview(authorAvatar)
        self.addSubview(authorNickname)
        self.clipsToBounds = true

        authorNickname.font = UIFont.fontStyle(for: kNickNameTextFontStyle).ratioFont
        applyColorScheme()
    }

    func setup(user: CommentUser?) {
        if let name = user?.nickName {
            UIImage.getAvatarPlaceholder(name: name, size: kAvatarImageViewSize) { [weak self] (image) in
                self?.authorAvatar.image = image
            }
        }

        authorNickname.text = user?.nickName ?? ""
        authorNickname.font = UIFont.fontStyle(for: kNickNameTextFontStyle).ratioFont
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        authorAvatar.frame = CGRect(x: 0, y: kAvatarTopPadding, width: kAvatarImageViewSize.width, height: kAvatarImageViewSize.height)
        authorAvatar.roundedRect(authorAvatar.bounds, byRoundingCorners: [.allCorners], cornerRadius: kAvatarCornerRadius)
        authorNickname.frame = CGRect(
            x: kAvatarImageViewSize.width + kNickNameLeftPadding,
            y: kAvatarTopPadding,
            width: self.bounds.width - kAvatarImageViewSize.width - kNickNameLeftPadding,
            height: kAvatarImageViewSize.height
        )
    }

    static func calculateCellHeight(user: CommentUser?, width: CGFloat) -> CGFloat {
        if user == nil {
            return 0
        }
        return kAvatarTopPadding + kAvatarImageViewSize.height
    }
}

extension ArticleChatAvatarView: Skinable {
    func applyColorScheme() {
        authorNickname.textColor = UIColor.color(for: kNickNameTextColorStyle)
    }
}
