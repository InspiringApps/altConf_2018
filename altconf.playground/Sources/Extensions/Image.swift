import Foundation
import AppKit

#if os(OSX)

public typealias Image = NSImage
extension Image {
	public static func withName(_ name: String) -> NSImage? {
		return NSImage(named: NSImage.Name(name))
	}

	public func doubleWidth() -> Image {

		let newSize = CGSize(width: self.size.width * 2, height: self.size.height)

		let scaledImage = Image(size: newSize, flipped: false, drawingHandler: { (rect) in
			self.draw(in: CGRect(origin: CGPoint(x: -self.size.width / 2, y: 0), size: self.size))
			return true
		})

		return scaledImage
	}
}

#else

public typealias Image = UIImage
extension Image {
	public static func withName(_ name: String) -> UIImage? {
		return UIImage(named: name)
	}

	public func doubleWidth() -> Image {

		let newSize = CGSize(width: self.size.width * 2, height: self.size.height)

		UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
		let context = UIGraphicsGetCurrentContext()!
		context.translateBy(x: self.size.width, y: 0)
		context.scaleBy(x: -self.scale, y: 1)

		self.draw(in: CGRect(origin: CGPoint(x: -self.size.width / 2, y: 0), size: self.size))

		if let scaledImage = UIGraphicsGetImageFromCurrentImageContext() {
			UIGraphicsEndImageContext()
			return scaledImage
		} else {
			UIGraphicsEndImageContext()
			return Image()
		}
	}
}

#endif

