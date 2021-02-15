
import Foundation
import UIKit

private let kAvatarFont = UIFont.SFSemibold(fontSize: 11)

public func floorToScreenPixels(scaleFactor: CGFloat, _ value: CGFloat) -> CGFloat {
    let scale = scaleFactor//NSScreen.main?.backingScaleFactor ?? 1.0
    return floor(value * scale) / scale
}

extension UIImage {

    private static func loadImageFromDiskWith(fileName: String) -> UIImage? {

        let documentDirectory = FileManager.SearchPathDirectory.documentDirectory

        let userDomainMask = FileManager.SearchPathDomainMask.userDomainMask
        let paths = NSSearchPathForDirectoriesInDomains(documentDirectory, userDomainMask, true)

        if let dirPath = paths.first {
            let imageUrl = URL(fileURLWithPath: dirPath).appendingPathComponent(fileName).appendingPathExtension("png")
            let image = UIImage(contentsOfFile: imageUrl.path)
            return image

        }
        return nil
    }

    static var gradientRandomColor: (UIColor, UIColor) {
        let gradients = [
            (UIColor(rgb: 0xF093FB), UIColor(rgb: 0xF5576C)),
            (UIColor(rgb: 0x43E97B), UIColor(rgb: 0x38F9D7)),
            (UIColor(rgb: 0x667EEA), UIColor(rgb: 0x764BA2)),
            (UIColor(rgb: 0x2AF598), UIColor(rgb: 0x009EFD)),
            (UIColor(rgb: 0x6A11CB), UIColor(rgb: 0x2575FC)),
            (UIColor(rgb: 0x4FACFE), UIColor(rgb: 0x00F2FE)),
            (UIColor(rgb: 0xFF0844), UIColor(rgb: 0xFFB199)),
            (UIColor(rgb: 0x112288), UIColor(rgb: 0x6713D2)),
            (UIColor(rgb: 0xFC6076), UIColor(rgb: 0xFF9A44)),
            (UIColor(rgb: 0xB7F8DB), UIColor(rgb: 0x50A7C2)),
            (UIColor(rgb: 0x50CC7F), UIColor(rgb: 0xF5D100)),
            (UIColor(rgb: 0x007ADF), UIColor(rgb: 0x00ECBC)),
            (UIColor(rgb: 0xF6D365), UIColor(rgb: 0xFDA085)),
            (UIColor(rgb: 0xA6C0FE), UIColor(rgb: 0xF68084)),
            (UIColor(rgb: 0x84FAB0), UIColor(rgb: 0x8FD3F4)),
            (UIColor(rgb: 0x0BA360), UIColor(rgb: 0x3CBA92)),
            (UIColor(rgb: 0x116655), UIColor(rgb: 0x50A7C2)),
            (UIColor(rgb: 0x9890E3), UIColor(rgb: 0xB1F4CF)),
            (UIColor(rgb: 0xB6CEE8), UIColor(rgb: 0xF578DC)),
            (UIColor(rgb: 0xF9D423), UIColor(rgb: 0xFF4E50))
        ]
        let random = Int(arc4random_uniform(UInt32(gradients.count)))
        return gradients[random]
    }

    private static func font(with bounds: CGRect) -> UIFont {
        return UIFont.SFSemibold(fontSize: bounds.height / 2)
    }

    static func generateImage(_ bounds: CGRect, with letters: String) -> UIImage {
        let originalBounds = bounds

        let bounds = CGRect(x: 0, y: 0, width: originalBounds.width * UIScreen.main.scale, height: originalBounds.height * UIScreen.main.scale)
        UIGraphicsBeginImageContext(bounds.size)
        let context = UIGraphicsGetCurrentContext()!

        context.beginPath()
        context.addEllipse(in: CGRect(x: 0.0, y: 0.0, width: bounds.size.width, height: bounds.size.height))
        context.clip()

        let colorsArray: NSArray = [ gradientRandomColor.0.cgColor, gradientRandomColor.1.cgColor ]

        var locations: [CGFloat] = [1.0, 0.0]

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let gradient = CGGradient(colorsSpace: colorSpace, colors: colorsArray, locations: &locations)!

        context.drawLinearGradient(gradient, start: CGPoint(x: 0.0, y: bounds.size.height / 2), end: CGPoint(x: bounds.size.height, y: bounds.size.height / 2 ), options: CGGradientDrawingOptions())

        context.setBlendMode(.normal)

        let attributedString = NSAttributedString(string: letters, attributes: [NSAttributedString.Key.font: font(with: bounds), NSAttributedString.Key.foregroundColor: UIColor.white])

        let line = CTLineCreateWithAttributedString(attributedString)
        let lineBounds = CTLineGetBoundsWithOptions(line, .useOpticalBounds)

        let lineOffset = CGPoint(x: letters == "B" ? 1.0 : 0.0, y: 0.0)

        let originX = floorToScreenPixels(scaleFactor: UIScreen.main.scale, ( -lineBounds.origin.x + (bounds.size.width - lineBounds.size.width) / 2.0) + lineOffset.x )
        let originY = floorToScreenPixels(scaleFactor: UIScreen.main.scale, ( -lineBounds.origin.y + (bounds.size.height - lineBounds.size.height) / 2.0))

        let lineOrigin = CGPoint(x: originX, y: originY)

        context.translateBy(x: bounds.size.width / 2.0, y: bounds.size.height / 2.0)
        context.scaleBy(x: 1.0, y: -1.0)
        context.translateBy(x: -bounds.size.width / 2.0, y: -bounds.size.height / 2.0)

        context.translateBy(x: lineOrigin.x, y: lineOrigin.y)
        CTLineDraw(line, context)
        context.translateBy(x: -lineOrigin.x, y: -lineOrigin.y)

        let image = UIImage(cgImage: context.makeImage()!)
        UIGraphicsEndImageContext()

        return image
    }

    private static func saveImage(imageName: String, image: UIImage) {
        DispatchQueue.global(qos: .background).async {
            guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }

            let fileName = imageName
            let fileURL = documentsDirectory.appendingPathComponent(fileName).appendingPathExtension("png")

            guard let data = image.pngData() else { return }

            if FileManager.default.fileExists(atPath: fileURL.path) {
                do {
                    try FileManager.default.removeItem(atPath: fileURL.path)
                    print("Removed old image")
                } catch let removeError {
                    print("couldn't remove file at path", removeError)
                }
            }
            do {
                try data.write(to: fileURL)
            } catch let error {
                print("error saving file with error", error)
            }
        }
    }

    static func getAvatarPlaceholder(name: String, size: CGSize, completedImage: @escaping ((UIImage) -> Void )) {
        DispatchQueue.global(qos: .utility).async {
            let words: [String] = name.components(separatedBy: " ")

            let rect = CGRect(origin: .zero, size: size)

            let name: String = words.count >= 2 ?  String(words[0].prefix(1) + words[1].prefix(1)).uppercased() : String(words[0].prefix(1)).uppercased()

            if let image = loadImageFromDiskWith(fileName: name) {
                DispatchQueue.main.async {
                    completedImage(image)
                }
            } else {
                let image = generateImage(rect, with: name)
                DispatchQueue.main.async {
                    completedImage(image)
                }
                saveImage(imageName: name, image: image)
            }
        }

    }

    func imageWithColor(tintColor: UIColor) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)

        guard let context = UIGraphicsGetCurrentContext()  else { return nil }

        context.translateBy(x: 0, y: size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        context.setBlendMode(.normal)

        let rect = CGRect.init(x: 0, y: 0, width: size.width, height: size.height)
        if let cgImage = cgImage {
            context.clip(to: rect, mask: cgImage)
        }

        tintColor.setFill()
        context.fill(rect)

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage
    }
}
