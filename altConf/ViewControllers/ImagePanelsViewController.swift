//  altConf
//  Created by Erwin Mazariegos on 6/3/18 using Swift 4.0.
//  Copyright © 2018 Erwin. All rights reserved.

import UIKit
import SceneKit
import ARKit

class ImagePanelsViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {

	@IBOutlet var sceneView: ARSCNView!

	let session = ARSession()

	let minimumPanelRadius: Float = 1.0
	let panelAnimationDuration = 1.0
	let baseNodeScale: CGFloat = 0.02

	let nameTextNode = SCNNode()
	let descriptionTextNode = SCNNode()

	var currentPanel: ImagePanel?
	var panelBaseRadius: Float = 0
	var panelMidPoint: Float = 0
	var panelSpacingDegrees: Float = 0

	override func viewDidLoad() {
		LogFunc()
		super.viewDidLoad()

		sceneView.delegate = self
		sceneView.session.delegate = self
		sceneView.scene = SCNScene()

		let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
		sceneView.addGestureRecognizer(tap)
	}

	override func viewWillAppear(_ animated: Bool) {
		LogFunc()
		super.viewWillAppear(animated)

		let configuration = ARWorldTrackingConfiguration()
		sceneView.session.run(configuration)

		addPanels()
		addTextNodes()
		addMob()
	}

	override func viewWillDisappear(_ animated: Bool) {
		LogFunc()
		super.viewWillDisappear(animated)
		sceneView.session.pause()
	}

	override func didReceiveMemoryWarning() {
		LogFunc()
		super.didReceiveMemoryWarning()
	}

	@objc
	func handleTap(sender: UITapGestureRecognizer) {
		LogFunc()

		moveCurrentPanelBack()

		let tapPoint = sender.location(in: sceneView)
		let results = sceneView.hitTest(tapPoint, options: nil)

		var tappedPanel: ImagePanel?

		results.forEach({ hitResult in

			if let geometry = hitResult.node.geometry,
				let parent = hitResult.node.parent as? ImagePanel {
				if let _ = geometry as? SCNBox {
					tappedPanel = parent
				} else if let _ = geometry as? SCNPlane {
					tappedPanel = parent
				}
			}
		})

		if let panel = tappedPanel {
			tapPanel(panel)
		}
	}

	func addPanels() {
		LogFunc()
		let imageMap = [
			("Fire Hill", "landscape1.jpg"),
			("Gate Up", "landscape2.jpg"),
			("San Jose", "landscape3.jpg"),
			("Golden Span", "landscape2.jpg"),
			("Gray Drama", "landscape3.jpg")
		]

		panelSpacingDegrees = 180.0 / Float(imageMap.count)
		panelMidPoint = 0.5 * Float(imageMap.count - 1)
		panelBaseRadius = max(minimumPanelRadius, Float(imageMap.count) * 1.4)

		for (index, map) in imageMap.enumerated() {
			let image = Image.withName(map.1)
			let imagePanel = ImagePanel(title: map.0, image: image, index: index)

			let degreesFromCenter = degreesFromCenterForPanelIndex(index)
			imagePanel.position = positionForDegreesFromCenter(degreesFromCenter, atRadius: panelBaseRadius)
			imagePanel.eulerAngles.y = -degreesFromCenter * (.pi / 180.0)

			sceneView.scene.rootNode.addChildNode(imagePanel)
		}
	}

	func addTextNodes() {
		LogFunc()
		let largeFontSize: CGFloat = 24
		let smallFontSize: CGFloat = 14

		let nameText = SCNText(string: "AltConf 2018", extrusionDepth: 2)
		nameText.font = .systemFont(ofSize: largeFontSize)
		nameText.materials = [SCNMaterial.white, SCNMaterial.white, SCNMaterial.black]	// front, back, extruded

		nameTextNode.geometry = nameText
		nameTextNode.pivotAtCorner(.allCorners)
		nameTextNode.position = positionForDegreesFromCenter(0, atRadius: panelBaseRadius * 0.9, yOffset: -2)
		nameTextNode.scale = SCNVector3(baseNodeScale, baseNodeScale, baseNodeScale)
		nameTextNode.eulerAngles.x = -45 * (.pi / 180)

		sceneView.scene.rootNode.addChildNode(nameTextNode)

		let descriptionText = SCNText(string: "AR + SceneKit Tips and Tricks", extrusionDepth: 2)
		descriptionText.font = .systemFont(ofSize: smallFontSize)
		descriptionText.materials = [SCNMaterial.white, SCNMaterial.white, SCNMaterial.black]	// front, back, extruded

		descriptionTextNode.geometry = descriptionText
		descriptionTextNode.pivotAtCorner(.allCorners)
		descriptionTextNode.position = positionForDegreesFromCenter(0, atRadius: panelBaseRadius * 0.8, yOffset: -2.5)
		descriptionTextNode.scale = SCNVector3(baseNodeScale, baseNodeScale, baseNodeScale)
		descriptionTextNode.eulerAngles.x = -45 * (.pi / 180)

		sceneView.scene.rootNode.addChildNode(descriptionTextNode)
	}

	func tapPanel(_ panel: ImagePanel) {
		LogFunc()

		moveCurrentPanelBack()

		if panel == currentPanel {
			currentPanel = nil
			return
		}

		currentPanel = panel

		if let image = panel.contentImage {

			// Create an image for the inner surface of a cylinder
			// Since we want the image to only render on half of the inner circumference,
			// we need to make a new image that is double the original width,
			// with the image contents in the center, and no content on the outer 1/4's of the width
			let image2 = image.doubleWidth()

			let imageMaterial = SCNMaterial()
			imageMaterial.diffuse.contents = image2
			imageMaterial.lightingModel = .constant	// so we don't have to point a light at it to see it
			imageMaterial.isDoubleSided = true

			let cylinderRadius: CGFloat = image.size.width * baseNodeScale / 3
			let cylinder = SCNCylinder(radius: cylinderRadius, height: image.size.height * baseNodeScale)
			cylinder.materials = [imageMaterial, SCNMaterial.clear, SCNMaterial.clear]

			panel.animateToOpacity(0, withDuration: panelAnimationDuration)

			panel.animateToRotationRadians(panel.eulerAngles.y + .pi / 2, withDuration: panelAnimationDuration / 2, completion: {

				self.sceneView.scene.rootNode.addChildNode(panel.imageNode)

				let initialScale = (panel.originalPanelGeometry.height / cylinder.height) * self.baseNodeScale * CGFloat(panel.scale.x)
				panel.imageNode.scale = SCNVector3(initialScale, initialScale, initialScale)
				panel.imageNode.geometry = cylinder

				panel.imageNode.animateRotationByRadians(180 * .pi / 180, withDuration: self.panelAnimationDuration)
				panel.imageNode.animateToScale(SCNVector3Make(1, 1, 1), withDuration: self.panelAnimationDuration * 2)
			})
		}
	}

	func moveCurrentPanelBack() {
		LogFunc()

		guard let panel = currentPanel else {
			LogFunc("no current panel")
			return
		}

		panel.imageNode.animateRotationByRadians(.pi / 4, withDuration: panelAnimationDuration)
		panel.imageNode.animateToPosition(panel.originalImageNodePosition, withDuration: panelAnimationDuration)
		// scale along z faster to keep cylinder close to panel node
		panel.imageNode.animateToScale(SCNVector3(0.2, 0.2, 0.05), withDuration: panelAnimationDuration, completion: {
			panel.animateToOpacity(1, withDuration: self.panelAnimationDuration)
			panel.imageNode.animateToScale(SCNVector3(0.05, 0.05, 0.01), withDuration: self.panelAnimationDuration)
			panel.addChildNode(panel.imageNode)
			panel.animateRotationByRadians(.pi / 2, withDuration: self.panelAnimationDuration / 2, completion: {
				panel.reset()
				panel.animateRotationByRadians(.pi, withDuration: self.panelAnimationDuration)
			})
		})
	}

	func positionForDegreesFromCenter(_ degrees: Float, atRadius radius: Float, xOffset: Float = 0, yOffset: Float = 0) -> SCNVector3 {
		let radiansFromCenter = degrees * (.pi / 180.0)
		let x: Float = sin(radiansFromCenter) * radius
		let z: Float = cos(radiansFromCenter) * radius
		return SCNVector3(x + xOffset, yOffset, -z)
	}

	func positionForRadiansFromCenter(_ radians: Float, atRadius radius: Float, yOffset: Float = 0) -> SCNVector3 {
		let degrees = -radians * 180 / .pi
		return positionForDegreesFromCenter(degrees, atRadius: radius, yOffset:yOffset)
	}

	func degreesFromCenterForPanelIndex(_ index: Int) -> Float {
		return ((Float(index) - panelMidPoint) * panelSpacingDegrees)
	}

	func addMob() {
		LogFunc()

		let scale: Float = 0.01
		let nodeScale = SCNVector3(scale, scale, scale)
		let mobZLimit = panelBaseRadius
		let mobZBaseRadius = panelBaseRadius * 4

		let lowerRange = 15
		let upperRange = 50
		let randomMobCount = lowerRange + Int(arc4random_uniform(UInt32(upperRange - lowerRange)))

		let angleLimit = 45
		let positionXLimit = view.frame.size.width / 2
		let positionYBase = -view.frame.size.height * 0.25
		let positionYLimit = view.frame.size.height * 0.25

		let personMaterial = SCNMaterial()
		personMaterial.diffuse.contents = SKTexture(imageNamed: "user-blue")
		personMaterial.transparent.contents = SKTexture(imageNamed: "user-blue")

		(0..<randomMobCount).forEach({ index in

			let randomX = (Float(-positionXLimit / 2) + Float(arc4random_uniform(UInt32(positionXLimit)))) * scale

			let randomY = (Float(-positionYLimit / 2) + Float(arc4random_uniform(UInt32(positionYLimit))) + Float(positionYBase)) * scale
			let randomZ = -(mobZBaseRadius - mobZLimit + Float(arc4random_uniform(UInt32(mobZLimit * 2))))
			let randomAngle = Float(-angleLimit) + Float(arc4random_uniform(UInt32(angleLimit * 2)))

			let randomMaterial = SCNMaterial()
			randomMaterial.diffuse.contents = personMaterial.diffuse.contents
			randomMaterial.transparent.contents = personMaterial.transparent.contents
			randomMaterial.transparency = alphaForZ(randomZ, baseRadius: mobZBaseRadius, zLimit: mobZLimit)

			let personObject = SCNBox(width: 200, height: 200, length: 0, chamferRadius: 0)
			personObject.materials = [personMaterial]
			let personNode = SCNNode(geometry: personObject)
			personNode.position = SCNVector3(randomX, randomY, randomZ)
			personNode.eulerAngles.y = randomAngle * (.pi / 180.0)
			personNode.scale = nodeScale
			sceneView.scene.rootNode.addChildNode(personNode)

			let randomZRange = Float(arc4random_uniform(UInt32(mobZLimit)))
			let randomZDirection = Float(Bool.randomSign())
			let randomZDuration = 5 + Double(arc4random_uniform(UInt32(15)))
			var zFrom = -mobZBaseRadius - randomZRange * randomZDirection
			var zTo = -mobZBaseRadius + randomZRange * randomZDirection

			if Bool.random() {
				let temp = zFrom
				zFrom = zTo
				zTo = temp
			}

			let animationZ = CABasicAnimation(keyPath: "position.z")
			animationZ.fromValue = zFrom
			animationZ.toValue = zTo
			animationZ.duration = randomZDuration
			animationZ.repeatCount = HUGE
			animationZ.autoreverses = true
			personNode.addAnimation(animationZ, forKey: "person move Z")

			let animationAlpha = CABasicAnimation(keyPath: "geometry.firstMaterial.transparency")
			animationAlpha.fromValue = alphaForZ(zFrom, baseRadius: mobZBaseRadius, zLimit: mobZLimit)
			animationAlpha.toValue = alphaForZ(zTo, baseRadius: mobZBaseRadius, zLimit: mobZLimit)
			animationAlpha.duration = randomZDuration
			animationAlpha.repeatCount = HUGE
			animationAlpha.autoreverses = true
			personNode.addAnimation(animationAlpha, forKey: "person alpha")

			let randomXRange = CGFloat(arc4random_uniform(UInt32(positionXLimit / 10)))
			let randomXDirection = CGFloat(Bool.randomSign())
			let randomXDuration = 7 + Double(arc4random_uniform(UInt32(20)))

			let animationX = CABasicAnimation(keyPath: "position.x")
			animationX.valueFunction = CAValueFunction(name: kCAValueFunctionTranslateX)
			animationX.fromValue = -randomXRange * randomXDirection
			animationX.toValue = randomXRange * randomXDirection
			animationX.duration = randomXDuration
			animationX.repeatCount = HUGE
			animationX.autoreverses = true
			personNode.addAnimation(animationX, forKey: "person move X")
		})
	}

	func alphaForZ(_ z: Float, baseRadius: Float, zLimit: Float) -> CGFloat {
		return CGFloat(1.0 - abs(-z - baseRadius - zLimit) / (zLimit * 2))
	}

	// MARK: - ARSessionDelegate
	func session(_ session: ARSession, didUpdate frame: ARFrame) {

		let cameraAngle = frame.camera.eulerAngles.y
		nameTextNode.position = positionForRadiansFromCenter(cameraAngle, atRadius: panelBaseRadius * 0.9, yOffset: nameTextNode.position.y)
		descriptionTextNode.position = positionForRadiansFromCenter(cameraAngle, atRadius: panelBaseRadius * 0.8, yOffset: descriptionTextNode.position.y)

		nameTextNode.eulerAngles.y = cameraAngle
		descriptionTextNode.eulerAngles.y = cameraAngle
	}

	func session(_ session: ARSession, didFailWithError error: Error) {
		LogFunc()
		// Present an error message to the user
	}

	func sessionWasInterrupted(_ session: ARSession) {
		LogFunc()
		// Inform the user that the session has been interrupted, for example, by presenting an overlay
	}

	func sessionInterruptionEnded(_ session: ARSession) {
		LogFunc()
		// Reset tracking and/or remove existing anchors if consistent tracking is required
	}


}

