// Erwin Mazariegos
// Altconf 2018: AR+SceneKit Tips & Tricks

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

		var currentPanel: ImagePanel?
		let panelAnimationDuration = 1.0
		var clickGesture: NSClickGestureRecognizer?
		var tappableNodes: [SCNNode]? {
			didSet {
				if tappableNodes != nil, clickGesture == nil {
					clickGesture = NSClickGestureRecognizer(target: self, action: #selector(handleClick(gesture:)))
					addGestureRecognizer(clickGesture ?? NSClickGestureRecognizer() )
				}
			}
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
			let panelBaseRadius: CGFloat = max(minimumPanelRadius, CGFloat(imageMap.count) * 0.8)
			let panelSpacingDegrees: CGFloat = 180.0 / CGFloat(imageMap.count) + 10
			let panelMidPoint: CGFloat = 0.5 * CGFloat(imageMap.count - 1)

			switch mode {
			case .single:

				let image = Image.withName(imageMap[0].1)
				let imagePanel = ImagePanel(title: imageMap[0].0, image: image, index: 0)
				sceneView.scene?.rootNode.addChildNode(imagePanel)

			case .many:

				for (index, map) in imageMap.enumerated() {
					let image = Image.withName(map.1)
					let imagePanel = ImagePanel(title: map.0, image: image, index: index)

					let degreesFromCenter = ((CGFloat(index) - panelMidPoint) * panelSpacingDegrees)
					imagePanel.position = positionForDegreesFromCenter(degreesFromCenter, atRadius: panelBaseRadius)
					imagePanel.eulerAngles.y = -degreesFromCenter * (.pi / 180.0)

					sceneView.scene?.rootNode.addChildNode(imagePanel)
				}

				let largeFontSize: CGFloat = 24
				let smallFontSize: CGFloat = 14

				let nameText = SCNText(string: "AltConf 2018", extrusionDepth: 2)
				nameText.font = .systemFont(ofSize: largeFontSize)
				nameText.materials = [SCNMaterial.white, SCNMaterial.white, SCNMaterial.black]	// front, back, extruded

				let nameTextNode = SCNNode()
				nameTextNode.geometry = nameText
				nameTextNode.pivotAtCorner(.allCorners)
				nameTextNode.position = positionForDegreesFromCenter(0, atRadius: 3, yOffset: -2)
				nameTextNode.scale = SCNVector3(0.02, 0.02, 0.02)
				nameTextNode.eulerAngles.x = -45 * (.pi / 180)

				sceneView.scene?.rootNode.addChildNode(nameTextNode)

				let descriptionText = SCNText(string: "AR + SceneKit Tips and Tricks", extrusionDepth: 2)
				descriptionText.font = .systemFont(ofSize: smallFontSize)
				descriptionText.materials = [SCNMaterial.white, SCNMaterial.white, SCNMaterial.black]	// front, back, extruded

				let descriptionTextNode = SCNNode()
				descriptionTextNode.geometry = descriptionText
				descriptionTextNode.pivotAtCorner(.allCorners)
				descriptionTextNode.position = positionForDegreesFromCenter(0, atRadius: 2.8, yOffset: -2.5)
				descriptionTextNode.scale = SCNVector3(0.02, 0.02, 0.02)
				descriptionTextNode.eulerAngles.x = -45 * (.pi / 180)

				sceneView.scene?.rootNode.addChildNode(descriptionTextNode)

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

		public func clickPanel(_ panel: ImagePanel) {
			LogFunc()

			moveCurrentPanelBack()

			if let panel = tappedPanel, let currentFrame = sceneView.session.currentFrame {

				if panel == currentPanel {
					currentPanel = nil
					return
				}

				let cameraAngle = currentFrame.camera.eulerAngles.y

				createFullImageNodeFromPanel(panel, withCameraAngle: cameraAngle)

				currentPanel = panel
			} else {
				currentPanel = nil
			}


		}

		func moveCurrentPanelBack() {
			LogFunc()

			guard let panel = currentPanel else {
				return
			}

			let panelDegrees = degreesFromCenterForPanelIndex(panel.panelIndex)

			panel.animateToPosition(positionForDegreesFromCenter(panelDegrees, atRadius: panelBaseRadius), withDuration: panelAnimationDuration)

			panel.animateToRotationRadians(panel.eulerAngles.y - .pi / 2, withDuration: self.panelAnimationDuration, completion: {
				panel.scale = self.nodeScale
				panel.restoreGeometry()
				panel.animateToRotationRadians(Float(-panelDegrees * (.pi / 180.0)), withDuration: self.panelAnimationDuration)
			})

		}

		func createFullImageNodeFromPanel(_ panel: ImagePanel, withCameraAngle cameraAngle: Float) {
			LogFunc()
			if let image = panel.geometry?.firstMaterial?.diffuse.contents as? Image {
				let image2 = doubleWidth(image: image)

				let imageMaterial = SCNMaterial()
				imageMaterial.diffuse.contents = image2
				imageMaterial.isDoubleSided = true

				let cylinderRadius: CGFloat = image.size.width * scale * 2
				let cylinder = SCNCylinder(radius: cylinderRadius, height: image.size.height * scale)
				cylinder.materials = [imageMaterial, SCNMaterial.black, SCNMaterial.black]

				let initialScale = (panel.panelGeometry.height / cylinder.height) * scale

				panel.animateToRotationRadians(panel.eulerAngles.y + .pi / 2, withDuration: panelAnimationDuration / 2, completion: {
					panel.scale = SCNVector3(initialScale, initialScale, initialScale)
					panel.geometry = cylinder
					panel.animateToRotationRadians(cameraAngle + .pi, withDuration: self.panelAnimationDuration)
					panel.animateToScale(SCNVector3Make(1, 1, 1), withDuration: self.panelAnimationDuration)
					panel.animateToPosition(SCNVector3(0, 0, 0), withDuration: self.panelAnimationDuration)
				})
			}
		}

		func doubleWidth(image: Image) -> Image {

			let size = image.size
			let newSize = CGSize(width: size.width * 2, height: size.height)

			UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
			let context = UIGraphicsGetCurrentContext()!
			context.translateBy(x: size.width, y: 0)
			context.scaleBy(x: -image.scale, y: 1)

			image.draw(in: CGRect(origin: CGPoint(x: -size.width / 2, y: 0), size: size))

			if let scaledImage = UIGraphicsGetImageFromCurrentImageContext() {
				UIGraphicsEndImageContext()
				return scaledImage
			} else {
				UIGraphicsEndImageContext()
				return UIImage()
			}
		}

		func degreesFromCenterForPanelIndex(_ index: Int) -> CGFloat {
			return ((CGFloat(index) - panelMidPoint) * panelSpacingDegrees)
		}


	}

}

