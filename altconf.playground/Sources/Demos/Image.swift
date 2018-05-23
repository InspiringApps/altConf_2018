import Foundation
import SceneKit
import SpriteKit

#if os(OSX)

public typealias Image = NSImage
extension Image {
	public static func withName(_ name: String) -> NSImage? {
		return NSImage(named: NSImage.Name(name))
	}
}

#else

public typealias Image = UIImage
extension Image {
	public static func withName(_ name: String) -> UIImage? {
		return UIImage(named: name)
	}
}

#endif

extension Demos {

	public struct Images {

		public enum DemoMode {
			case single, many
		}

		public static func runwithView(_ sceneView: ARView, mode: DemoMode) {

			let imageMap = [
				("Test 1", "landscape1.jpg"),
				("Test 2", "landscape2.jpg"),
				("Test 3", "landscape3.jpg")
			]

			for (index, map) in imageMap.enumerated() {
				let image = Image.withName(map.0)
				let imagePanel = ImageNode(title: map.1, image: image, index: index)

				imagePanel.position.y = CGFloat(index)
				sceneView.scene?.rootNode.addChildNode(imagePanel)

			}



			switch mode {
			case .single:
				break
			case .many:
				break

			}
		}

		func panelWithTitle(_ title: String, imageName: String, index: Int) -> ImageNode {
			let image = Image.withName(imageName)
			return ImageNode(title: title, image: image, index: index)
		}

	}

}

