
import Foundation
import UIKit

private let kIcoSize = CGSize(width: 12, height: 12)
private let kIcoSpaceBetween: CGFloat = 2
private let kIcoRightPadding: CGFloat = 5
private let kEmotionsIconsCount = 3

private let kCounterFontStyle = FontStyleName.paragraph2Reg

private let kWhiteSchemeTextColorStyle = ColorSchemeName.informationFont
private let kBlueSchemeTextColorStyle = ColorSchemeName.myMessageFont
private let kWhiteSchemeBackgroundColorStyle = ColorSchemeName.otherMessage
private let kBlueSchemeBackgroundColorStyle = ColorSchemeName.myMessage

class ArticleChatEmotionsCountView: UIView {

    private var emotions: EmotionsModel?
    private var colorScheme: CommentColorScheme = .white
    private var count: Int = 0

    private (set) var icoList: [UIImageView] = {
        var icoList = [UIImageView]()
        for index in 0..<kEmotionsIconsCount {
            icoList.append(UIImageView())
        }
        return icoList
    }()

    private (set) var counter: UILabel = {
        let counter = UILabel()
        return counter
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        self.addSubview(counter)
        for index in 0..<kEmotionsIconsCount {
            self.addSubview(icoList[index])
        }

        counter.font = UIFont.fontStyle(for: kCounterFontStyle).ratioFont
    }

    func setup(model: EmotionsModel?, colorScheme: CommentColorScheme) {

        var count = 0
        if let emoutionsValues = model?.emotions?.compactMap({$0.count}) {
            count  = emoutionsValues.reduce(0) { $0 + $1}
        }

        self.count = count
        self.colorScheme = colorScheme

        self.counter.text = String(count)

        if colorScheme == .white {
            self.counter.textColor = UIColor.color(for: kWhiteSchemeTextColorStyle)
            self.counter.backgroundColor = UIColor.color(for: kWhiteSchemeBackgroundColorStyle)
        } else if colorScheme == .blue {
            self.counter.textColor = UIColor.color(for: kBlueSchemeTextColorStyle)
            self.counter.backgroundColor = UIColor.color(for: kBlueSchemeBackgroundColorStyle)
        }

        fillViewsWithImages(model: model, colorScheme: colorScheme)

        counter.font = UIFont.fontStyle(for: kCounterFontStyle).ratioFont
    }

    private func fillViewsWithImages(model: EmotionsModel?, colorScheme: CommentColorScheme) {
        let filteredEmotions = model?.emotions?.filter({ (emotion) -> Bool in
            return emotion.count ?? 0 > 0
        })

        let sortedEmotions = filteredEmotions?.sorted(by: { (le, re) -> Bool in
            return le.count ?? 0 > re.count ?? 0
        })

        icoList.forEach { (view) in
            view.isHidden = true
        }

        if let emotions = sortedEmotions, let sortedEmotionsCount = sortedEmotions?.count {
            var index = sortedEmotionsCount < kEmotionsIconsCount ? (kEmotionsIconsCount - sortedEmotionsCount) : 0
            for emotion in emotions {
                if index < icoList.count {
                    icoList[index].isHidden = false
                    icoList[index].image = imageForEmotion(type: emotion.type, colorScheme: colorScheme)
                    index += 1
                } else {
                    break
                }
            }
        }
    }

    private func imageForEmotion(type: EmotionType, colorScheme: CommentColorScheme) -> UIImage? {
        let imagePostfix = colorScheme == .white ? "Colorized" : "White"
        return UIImage(named: type.rawValue + imagePostfix)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let counterSize = String(count).boundingSize(
            with: .greatestFiniteMagnitude,
            attributes: [.font: UIFont.fontStyle(for: kCounterFontStyle).ratioFont]
        )

        counter.frame = CGRect(
            x: self.bounds.width - counterSize.width,
            y: 0,
            width: counterSize.width,
            height: max(kIcoSize.height, counterSize.height)
        )

        let emotionsWidth = CGFloat(kEmotionsIconsCount)*(kIcoSize.width + kIcoSpaceBetween) - kIcoSpaceBetween
        let totalWidth = emotionsWidth + kIcoRightPadding + counterSize.width
        for index in 0..<kEmotionsIconsCount {
            let icoView = icoList[index]
            let xPos = self.bounds.width - totalWidth + CGFloat(index)*(kIcoSize.width + kIcoSpaceBetween)
            icoView.frame = CGRect(x: xPos, y: 0, width: kIcoSize.width, height: kIcoSize.height)
        }

        if counterSize.height > kIcoSize.height {
            for index in 0..<kEmotionsIconsCount {
                icoList[index].center = CGPoint(x: icoList[index].frame.midX, y: counter.frame.midY)
            }
        }
    }

    static func calculateSize(model: EmotionsModel?, colorScheme: CommentColorScheme) -> CGSize {

        var count = 0
        if let emoutionsValues = model?.emotions?.compactMap({$0.count}) {
            count  = emoutionsValues.reduce(0) { $0 + $1}
        }

        let counterSize = String(count).boundingSize(
            with: .greatestFiniteMagnitude,
            attributes: [.font: UIFont.fontStyle(for: kCounterFontStyle).ratioFont]
        )

        let emotionsWidth = CGFloat(kEmotionsIconsCount)*(kIcoSize.width + kIcoSpaceBetween) - kIcoSpaceBetween
        let totalWidth = emotionsWidth + kIcoRightPadding + counterSize.width
        return CGSize(width: round(totalWidth), height: max(kIcoSize.height, counterSize.height))
    }

}
