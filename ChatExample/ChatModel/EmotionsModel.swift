
import Foundation

enum EmotionType: String, CaseIterable {
    case like, haha, wow, sad, angry, dislike
}

struct Emotion {
    let type: EmotionType
    let count: Int?

    init(type: EmotionType, count: Int?) {
        self.type = type
        self.count = count
    }

}

struct EmotionsModel {
    let emotions: [Emotion]?

    init(
        like: Int? = nil,
        angry: Int? = nil,
        dislike: Int? = nil,
        sad: Int? = nil,
        wow: Int? = nil,
        haha: Int? = nil
    ) {
        emotions = [
            Emotion(type: .like, count: like),
            Emotion(type: .angry, count: angry),
            Emotion(type: .dislike, count: dislike),
            Emotion(type: .sad, count: sad),
            Emotion(type: .wow, count: wow),
            Emotion(type: .haha, count: haha)
        ]
    }

    init(comment: CommentData) {
        emotions = [
            Emotion(type: .like, count: comment.like),
            Emotion(type: .angry, count: comment.angry),
            Emotion(type: .dislike, count: comment.dislike),
            Emotion(type: .sad, count: comment.sad),
            Emotion(type: .wow, count: comment.wow),
            Emotion(type: .haha, count: comment.haha)
        ]
    }
}
