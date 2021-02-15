
import Foundation
import UIKit

struct ColorScheme {
    let light: UIColor
    let dark: UIColor

    private var lightSource: String
    private var darkSource: String?
}

extension ColorScheme: Decodable {

    enum CodingKeys: String, CodingKey {
        case lightSource = "light"
        case darkSource = "dark"
    }

    init(from decoder: Decoder) throws {
        let containder = try decoder.container(keyedBy: CodingKeys.self)

        lightSource = try containder.decode(String.self, forKey: .lightSource)
        darkSource = try? containder.decode(String.self, forKey: .darkSource)

        light = UIColor.init(hex: lightSource)
        if let dSource = darkSource {
            dark = UIColor.init(hex: dSource)
        } else {
            dark = UIColor.clear
        }

    }
}
