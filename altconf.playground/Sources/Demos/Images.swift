// Erwin Mazariegos
// Altconf 2018: AR+SceneKit Tips & Tricks

import Foundation
import SceneKit
import SpriteKit

public extension Demos {

	public class Images {

		public enum DemoMode {
			case single, many
		}

		let panelAnimationDuration = 1.0
		let baseNodeScale: CGFloat = 0.02

		var currentPanel: ImagePanel?
		var panelBaseRadius: CGFloat = 1.0
		var panelMidPoint: CGFloat = 0
		var panelSpacingDegrees: CGFloat = 0
		var clickGesture: NSClickGestureRecognizer?
		var demoSceneView: ARView?

		public init() {
			LogFunc()
		}

		public func runwithView(_ sceneView: ARView, mode: DemoMode) {
			LogFunc()

			let imageMap = [
				("Fire Hill", "landscape1.jpg"),
				("Gate Up", "landscape2.jpg"),
				("San Jose", "landscape3.jpg"),
				("Golden Span", "landscape2.jpg"),
				("Gray Drama", "landscape3.jpg")
			]

			let minimumPanelRadius: CGFloat = 1.0

			panelSpacingDegrees = 180.0 / CGFloat(imageMap.count) + 10
			panelMidPoint = 0.5 * CGFloat(imageMap.count - 1)
			panelBaseRadius = max(minimumPanelRadius, CGFloat(imageMap.count) * 0.8)

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
				nameTextNode.scale = SCNVector3(baseNodeScale, baseNodeScale, baseNodeScale)
				nameTextNode.eulerAngles.x = -45 * (.pi / 180)

				sceneView.scene?.rootNode.addChildNode(nameTextNode)

				let descriptionText = SCNText(string: "AR + SceneKit Tips and Tricks", extrusionDepth: 2)
				descriptionText.font = .systemFont(ofSize: smallFontSize)
				descriptionText.materials = [SCNMaterial.white, SCNMaterial.white, SCNMaterial.black]	// front, back, extruded

				let descriptionTextNode = SCNNode()
				descriptionTextNode.geometry = descriptionText
				descriptionTextNode.pivotAtCorner(.allCorners)
				descriptionTextNode.position = positionForDegreesFromCenter(0, atRadius: 2.8, yOffset: -2.5)
				descriptionTextNode.scale = SCNVector3(baseNodeScale, baseNodeScale, baseNodeScale)
				descriptionTextNode.eulerAngles.x = -45 * (.pi / 180)

				sceneView.scene?.rootNode.addChildNode(descriptionTextNode)

				demoSceneView = sceneView
				if clickGesture == nil {
					clickGesture = NSClickGestureRecognizer(target: sceneView, action: #selector(sceneView.handleClick(gesture:)))
					sceneView.addGestureRecognizer(clickGesture ?? NSClickGestureRecognizer() )

					sceneView.clickAction = { (anyNode) in
						if let panel = anyNode as? ImagePanel {
							self.clickPanel(panel)
						}
					}
				}

			}
		}

		func positionForDegreesFromCenter(_ degrees: CGFloat, atRadius radius: CGFloat, xOffset: CGFloat = 0, yOffset: CGFloat = 0) -> SCNVector3 {
			let radiansFromCenter = degrees * (.pi / 180.0)
			let x: CGFloat = sin(radiansFromCenter) * radius
			let z: CGFloat = cos(radiansFromCenter) * radius
			return SCNVector3(x + xOffset, yOffset, -z)
		}

		func positionForRadiansFromCenter(_ radians: Float, atRadius radius: CGFloat, yOffset: Float = 0) -> SCNVector3 {
			let degrees = CGFloat(-radians * 180 / .pi)
			return positionForDegreesFromCenter(degrees, atRadius: radius, yOffset:CGFloat(yOffset))
		}

		public func clickPanel(_ panel: ImagePanel) {
			LogFunc()

			moveCurrentPanelBack()

			currentPanel = panel

			if let image = panel.contentImage {
				let image2 = image.doubleWidth()

				let imageMaterial = SCNMaterial()
				imageMaterial.diffuse.contents = image2
				imageMaterial.lightingModel = .constant
				imageMaterial.isDoubleSided = true

				let cylinderRadius: CGFloat = image.size.width * baseNodeScale
				let cylinder = SCNCylinder(radius: cylinderRadius, height: image.size.height * baseNodeScale)
				cylinder.materials = [imageMaterial, SCNMaterial.clear, SCNMaterial.clear]

				panel.animateToRotationRadians(panel.eulerAngles.y + .pi / 2, withDuration: panelAnimationDuration / 2, completion: {
					let initialScale = (panel.originalPanelGeometry.height / cylinder.height) * self.baseNodeScale
					panel.imageNode.scale = SCNVector3(initialScale, initialScale, initialScale)
					panel.imageNode.geometry = cylinder
					panel.imageNode.eulerAngles.y = -.pi

					panel.imageNode.animateToRotationRadians(-135 * .pi / 180, withDuration: self.panelAnimationDuration)
					panel.imageNode.animateToScale(SCNVector3Make(1, 1, 1), withDuration: self.panelAnimationDuration)

					// since node is now rotated 90 deg, moving along -x axis brings it closer to camera
					panel.imageNode.animateToPosition(SCNVector3(-10, 0, 0), withDuration: self.panelAnimationDuration)
				})
			}
		}

		func moveCurrentPanelBack() {
			LogFunc()

			guard let panel = currentPanel else {
				return
			}

			panel.imageNode.animateRotationByRadians(.pi / 4, withDuration: panelAnimationDuration)
			panel.imageNode.animateToPosition(panel.originalImageNodePosition, withDuration: panelAnimationDuration)
			// scale along z faster to keep cylinder close to panel node
			panel.imageNode.animateToScale(SCNVector3(0.2, 0.2, 0.05), withDuration: panelAnimationDuration, completion: {
				panel.imageNode.animateToScale(SCNVector3(0.05, 0.05, 0.01), withDuration: self.panelAnimationDuration)
				panel.animateRotationByRadians(.pi / 2, withDuration: self.panelAnimationDuration / 2, completion: {
					panel.restoreGeometry()
					panel.animateRotationByRadians(.pi, withDuration: self.panelAnimationDuration)
				})
			})

		}

		func degreesFromCenterForPanelIndex(_ index: Int) -> CGFloat {
			return ((CGFloat(index) - panelMidPoint) * panelSpacingDegrees)
		}


	}

}

