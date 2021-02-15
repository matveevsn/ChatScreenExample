
import Foundation
import UIKit

class CustomActionSheetViewController: UIViewController {

    var defaultActionSheetBuilder: CustomActionSheetViewModelBuilder = CustomActionSheetViewModelBuilderImpl()
    var viewWillTransition: (() -> Void)?
    var onClose: (() -> Void)?
    var onActionSheetWillAppearWithHeight: ((CGFloat) -> Void)?
    var actionSheetHeight: CGFloat {
        return CustomActionSheetView.calculateHeight(models: defaultActionSheetBuilder.actions())
    }

    private let customSheetView: CustomActionSheetView = {
        let customSheetView = CustomActionSheetView()
        return customSheetView
    }()

    public func addRegularAction(title: String, handler: (() -> Void)?) {
        defaultActionSheetBuilder.addAction(title: title, type: .regular, handler: handler)
    }

    public func addCancelAction(title: String, handler: (() -> Void)?) {
        defaultActionSheetBuilder.addAction(title: title, type: .cancel, handler: handler)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .clear
        self.view.addSubview(customSheetView)

        customSheetView.snp.makeConstraints { (make) in
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
            } else {
                make.bottom.equalTo(self.view)
            }
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.top.equalTo(self.view)
        }

        customSheetView.setupView(model: defaultActionSheetBuilder.actions())

        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(onActionViewTap(recognizer:)))
        tapRecognizer.delegate = self
        customSheetView.addGestureRecognizer(tapRecognizer)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        onActionSheetWillAppearWithHeight?(CustomActionSheetView.calculateHeight(models: defaultActionSheetBuilder.actions()))
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        self.viewWillTransition?()
    }

    @objc func onActionViewTap(recognizer: UITapGestureRecognizer) {
        self.dismiss(animated: true, completion: nil)
        self.onClose?()
    }
}

extension CustomActionSheetViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if let descendantView = self.customSheetView.hitTest(touch.location(in: self.customSheetView), with: nil) {
            if descendantView.isDescendant(of: self.customSheetView.buttonsTable) {
                return false
            }
        }
        return true
    }
}
