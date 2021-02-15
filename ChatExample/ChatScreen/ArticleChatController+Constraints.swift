
import Foundation
import UIKit

private let kUnreadViewMargin = isPhone() ? UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 7)
                                          : UIEdgeInsets(top: 0, left: 0, bottom: 15, right: 20)

extension ArticleChatController {

    func applyConstraints() {

        let navViewTopOffset = navigationBarOffset(isHasInformer: false)
        navView.snp.makeConstraints { (make) in
            make.top.equalTo(self.view).offset(navViewTopOffset)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.height.equalTo(self.navigationController?.navigationBar.frame.size.height ?? kDefaultNavViewHeight)
        }

        topPadView.snp.makeConstraints { (make) in
            make.top.equalTo(self.view)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.bottom.equalTo(navView)
        }

        chatListView.snp.makeConstraints { (make) in
            make.top.equalTo(navView.snp.bottom)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.bottom.equalTo(sendView.snp.top)
            make.height.greaterThanOrEqualTo(kMinimumHeight)
        }

        sendView.snp.makeConstraints { (make) in
            if #available(iOS 11.0, *) {
                sendViewBottomConstraint = make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).constraint
            } else {
                sendViewBottomConstraint = make.bottom.equalTo(self.bottomLayoutGuide.snp.top).constraint
            }
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
        }

        unreadView.snp.makeConstraints { (make) in
            make.bottom.equalTo(chatListView).offset(-kUnreadViewMargin.bottom)
            make.right.equalTo(self.view).offset(-kUnreadViewMargin.right)
        }

        shadowView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
    }

    func navigationBarOffset(isHasInformer: Bool) -> CGFloat {
        let statusBar = UIApplication.shared.statusBarFrame.size.height
        return statusBar + (isHasInformer ? 52 : 0)
    }

}
