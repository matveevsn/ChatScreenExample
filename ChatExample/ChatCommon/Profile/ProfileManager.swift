
import Foundation

protocol ProfileManagerInterface {
    var profile: UserProfile? { get }
}

class ProfileManager {
    static var shared: ProfileManagerInterface = {
        let instance = ProfileManager()

        return instance
    }()

    var userProfile: UserProfile? {
        get {
            return UserProfile( placeholder: "placeholder")
        }
        set {
        }
    }
}

extension ProfileManager: ProfileManagerInterface {
    var profile: UserProfile? {
        return userProfile
    }
}
