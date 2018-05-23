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
			LogFunc()

			let imageMap = [
				("Fire Hill", "landscape1.jpg"),
				("Gate Up", "landscape2.jpg"),
				("San Jose", "landscape3.jpg"),
				("Golden Span", "landscape2.jpg"),
				("Gray Drama", "landscape3.jpg")
			]

			let minimumPanelRadius: CGFloat = 1.0
			let panelBaseRadius: CGFloat = max(minimumPanelRadius, CGFloat(imageMap.count) * 0.9)
			let panelSpacingDegrees: CGFloat = 180.0 / CGFloat(imageMap.count) + 10
			let panelMidPoint: CGFloat = 0.5 * CGFloat(imageMap.count - 1)

			for (index, map) in imageMap.enumerated() {
				let image = Image.withName(map.1)
				let imagePanel = ImagePanel(title: map.0, image: image, index: index)

				let degreesFromCenter = ((CGFloat(index) - panelMidPoint) * panelSpacingDegrees)
				imagePanel.position = positionForDegreesFromCenter(degreesFromCenter, atRadius: panelBaseRadius)
				imagePanel.eulerAngles.y = -degreesFromCenter * (.pi / 180.0)

				sceneView.scene?.rootNode.addChildNode(imagePanel)
			}

			switch mode {
			case .single:
				break
			case .many:
				break

			}
		}

		static func positionForDegreesFromCenter(_ degrees: CGFloat, atRadius radius: CGFloat, xOffset: CGFloat = 0, yOffset: CGFloat = 0) -> SCNVector3 {
			let radiansFromCenter = degrees * (.pi / 180.0)
			let x: CGFloat = sin(radiansFromCenter) * radius
			let z: CGFloat = cos(radiansFromCenter) * radius
			return SCNVector3(x + xOffset, yOffset, -z)
		}

		static func positionForRadiansFromCenter(_ radians: Float, atRadius radius: CGFloat, yOffset: Float = 0) -> SCNVector3 {
			let degrees = CGFloat(-radians * 180 / .pi)
			return positionForDegreesFromCenter(degrees, atRadius: radius, yOffset:CGFloat(yOffset))
		}


	}

}

