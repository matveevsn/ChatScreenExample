
import Foundation
import SnapKit

private let kChatNavPadViewBackgroundColorStyle = ColorSchemeName.otherBackground
private let kBackgroundColorStyle = ColorSchemeName.otherBackground

private let kChatListMoveAnimationDuration = 0.2
private let kBarsShadowOpacity: Float = 0.05
private let kBarsShadowRadius: CGFloat = 1

class ArticleChatController: UIViewController {

    let kMinimumHeight: CGFloat = 60
    let kDefaultNavViewHeight: CGFloat = 44
    let kMessageMargin: CGFloat = 5
    let kLongPressAnimationDuration = 0.2

    var onClose: (() -> Void)?

    var sendViewBottomConstraint: Constraint?
    var commentsList: ChatCommentsListModel?
    var shouldCloseOnArticleOpen = false

    private var observation: NSKeyValueObservation?
    private (set) var fontSizeWasChanged: Bool = false

    private (set) var chatListView: ArticleChatListView = {
        let listView = ArticleChatListView(frame: .zero)
        return listView
    }()

    private (set) var navView: ArticleChatNavView = {
        let articleChatNavView = ArticleChatNavView(frame: .zero)
        return articleChatNavView
    }()

    private (set) var sendView: ArticleChatSendView = {
        let sendView = ArticleChatSendView(frame: .zero)
        return sendView
    }()

    private (set) var unreadView: ArticleChatUnreadView = {
        let view = ArticleChatUnreadView()
        return view
    }()

    private (set) var shadowView: UIView = {
        let shadowView = UIView()
        shadowView.backgroundColor = .black
        shadowView.alpha = 0.5
        return shadowView
    }()

    private (set) var topPadView: UIView = {
        let topPadView = UIView()
        return topPadView
    }()

    init(model: ChatCommentsListModel) {
        self.commentsList = model
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.isUserInteractionEnabled = true

        self.view.addSubview(chatListView)
        self.view.addSubview(topPadView)
        self.view.addSubview(navView)
        self.view.addSubview(sendView)
        self.view.addSubview(unreadView)
        self.view.addSubview(shadowView)

        applyConstraints()

        chatListView.interactiveDelegate = self
        sendView.sendViewDelegate = self
        unreadView.unreadDelegate = self
        navView.interactiveDelegate = self

        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(onShadowViewTap(recognizer:)))
        shadowView.addGestureRecognizer(tapRecognizer)

        navView.backButton.addTarget(self, action: #selector(onBack), for: .touchUpInside)
        navView.rightButton.addTarget(self, action: #selector(onSubscribe), for: .touchUpInside)

        resetViews()

        initializeModelListHandlers()

        updateModelList()

        setupObservers()
        applySkin()

        NotificationCenter.default.addObserver(self, selector: #selector(didEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleFontChange), name: .fontScaleChanged, object: nil)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return statusBarStyle
    }

    private func resetViews() {
        shadowView.isHidden = true
        navView.hideSeparator()
    }

    private func setup(model: ChatCommentsListModel) {
        self.commentsList = model
        resetViews()
        initializeModelListHandlers()
        updateModelList()
    }

    private func setupObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.keyboardNotification(notification:)),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil
        )

        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissKeyboard)
        )

        tap.cancelsTouchesInView = false
        chatListView.addGestureRecognizer(tap)

        observation = sendView.observe(\ArticleChatSendView.bounds, options: [.new, .old]) { [weak self] (_, change) in
            if let oldRect = change.oldValue,
                let newRect = change.newValue,
                oldRect != .zero {
                let offset = newRect.size.height - oldRect.size.height
                UIView.animate(withDuration: kChatListMoveAnimationDuration, animations: { [weak self] in
                    guard let self = self else { return }
                    self.chatListView.tableView.contentOffset = CGPoint(x: self.chatListView.tableView.contentOffset.x, y: self.chatListView.tableView.contentOffset.y + offset)
                })
            }
        }
    }

    private func updateAppearanceIfNeed() {
        if fontSizeWasChanged {
            self.view.subviews.forEach { ($0 as? ArticleChatScreenAppearanceUpdate)?.updateAppearance() }
            chatListView.tableView.reloadData()
            fontSizeWasChanged = false
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        updateAppearanceIfNeed()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        commentsList?.setTypedMessage(message: sendView.textView.textView.text)
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        var shouldDismissKeyboard = false

        coordinator.animate(alongsideTransition: { _ in
            self.chatListView.reloadView()
            shouldDismissKeyboard = self.sendView.dismissKeyboardIfNeed()
        }, completion: { _ in
            if shouldDismissKeyboard {
                self.sendView.showKeyboard()
            }
        })
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let typedMessage = commentsList?.typedMessage() {
            sendView.setup(message: typedMessage)
            commentsList?.setTypedMessage(message: nil)
        }
    }

    @objc func onBack() {
        self.onClose?()
        _ = self.sendView.dismissKeyboardIfNeed()
    }

    @objc func onSubscribe() {
    }

    @objc private func didEnterBackground() {
        commentsList?.setTypedMessage(message: sendView.textView.textView.text)
    }

    @objc private func handleFontChange() {
        fontSizeWasChanged = true
    }
}

extension ArticleChatController: UnreadViewDelegate {
    func onBottomButton() {
        chatListView.scrollToBottom(animated: true)
    }
}

extension ArticleChatController: SkinableController {
    func applySkin() {
        self.view.backgroundColor = UIColor.color(for: kBackgroundColorStyle)
        topPadView.backgroundColor = UIColor.color(for: kChatNavPadViewBackgroundColorStyle)
        navView.backgroundColor = UIColor.color(for: kChatNavPadViewBackgroundColorStyle)

        chatListView.applyColorScheme()
        navView.applyColorScheme()
        sendView.applyColorScheme()
        unreadView.applyColorScheme()
    }
}
