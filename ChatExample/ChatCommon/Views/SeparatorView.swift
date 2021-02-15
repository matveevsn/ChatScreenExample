
import Foundation
import UIKit

private let kSeparatorHeight: CGFloat = 1

class SeparatorView: UIView {

    private let isTop: Bool
    private let isBottom: Bool

    private (set) var topSeparator: UIView = {
        let separator = UIView()
        return separator
    }()

    private (set) var bottomSeparator: UIView = {
        let separator = UIView()
        return separator
    }()

    init(topSeparator: Bool = false, bottomSeparator: Bool = false) {
        isTop = topSeparator
        isBottom = bottomSeparator
        super.init(frame: .zero)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupView() {
        if isTop {
            self.addSubview(topSeparator)
            topSeparator.snp.makeConstraints { (make) in
                make.top.equalToSuperview()
                make.left.equalToSuperview()
                make.right.equalToSuperview()
                make.height.equalTo(kSeparatorHeight)
            }
        }

        if isBottom {
            self.addSubview(bottomSeparator)
            bottomSeparator.snp.makeConstraints { (make) in
                make.bottom.equalToSuperview()
                make.height.equalTo(kSeparatorHeight)
                make.left.equalToSuperview()
                make.right.equalToSuperview()
            }
        }
    }
}
