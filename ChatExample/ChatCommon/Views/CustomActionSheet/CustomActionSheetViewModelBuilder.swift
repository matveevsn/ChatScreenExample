
import Foundation
import UIKit

protocol CustomActionSheetViewModelBuilder {
    mutating func addAction(title: String, type: ActionType, handler: (() -> Void)?)
    func actions() -> [ActionItemModel]
}

struct CustomActionSheetViewModelBuilderImpl: CustomActionSheetViewModelBuilder {
    var regularActionsList = [ActionItemModel]()
    var cancelAction: ActionItemModel?

    mutating func addAction(title: String, type: ActionType, handler: (() -> Void)?) {
        if type == .regular {
            regularActionsList.append(ActionItemModel(title: title, appearanceType: .single, actionType: type, handler: handler))
        } else if type == .cancel {
            cancelAction = ActionItemModel(title: title, appearanceType: .single, actionType: type, handler: handler)
        }
        rebuildAppearanceType()
    }

    mutating private func rebuildAppearanceType() {
        for index in 0..<regularActionsList.count {
            if index == 0 && regularActionsList.count == 1 {
                regularActionsList[index].appearanceType = .single
            } else if index == 0 && index + 1 < regularActionsList.count {
                regularActionsList[index].appearanceType = .top
            } else if index > 0 && index + 1 < regularActionsList.count {
                regularActionsList[index].appearanceType = .middle
            } else if index > 0 {
                regularActionsList[index].appearanceType = .bottom
            }
        }
    }

    func actions() -> [ActionItemModel] {
        var actions = regularActionsList
        if let action = cancelAction {
            actions.append(action)
        }
        return actions
    }
}
