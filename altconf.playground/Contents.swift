//: A Cocoa based Playground to present user interface

// spritekit video
// portal w/ altconf logo inside
// panel to image morph
// panel spotlight
// animated people in audience

import AppKit
import PlaygroundSupport
import SceneKit
import SpriteKit

// create custom SCNView with default camera interactivity and optional rotatable node handling
let sceneView = ARView(frame: CGRect(x: 0, y: 0, width: 600, height: 1000))

// add own camera to replace default camera, for better control of initial view
let cameraNode = SCNNode()
cameraNode.camera = SCNCamera()
cameraNode.position = SCNVector3(x: 0, y: 0, z: 10)
cameraNode.look(at: SCNVector3(x: 0, y: 0, z: 0))
sceneView.scene?.rootNode.addChildNode(cameraNode)

//Demos.Measurement.runwithView(sceneView, mode: .random)

//Demos.Text.runwithView(sceneView, mode: .addSomeGray)

let here = true

if !here {
	let imageDemo = Demos.Images()
	imageDemo.runwithView(sceneView, mode: .many)
}

func positionForDegreesFromCenter(_ degrees: CGFloat, atRadius radius: CGFloat, xOffset: CGFloat = 0, yOffset: CGFloat = 0) -> SCNVector3 {
	let radiansFromCenter = degrees * (.pi / 180.0)
	let x: CGFloat = sin(radiansFromCenter) * radius
	let z: CGFloat = cos(radiansFromCenter) * radius
	return SCNVector3(x + xOffset, yOffset, -z)
}

let originalPosition = positionForDegreesFromCenter(25, atRadius: 4)
let originalRotation: CGFloat = -25 * (.pi / 180.0)

let image = Image.withName("landscape1.jpg")
let imagePanel = ImagePanel(title: "Testing Stuff", image: image, index: 0)
imagePanel.position = originalPosition
imagePanel.eulerAngles.y = originalRotation
if here {
	sceneView.scene?.rootNode.addChildNode(imagePanel)
}

var originalImageNodeScale = imagePanel.imageNode.scale
var originalImageNodePosition = imagePanel.imageNode.position

let baseNodeScale: CGFloat = 0.02
let panelAnimationDuration = 1.0

func doubleWidth(_ image: Image) -> Image {

	let newSize = CGSize(width: image.size.width * 2, height: image.size.height)

	let scaledImage = Image(size: newSize, flipped: true, drawingHandler: { (rect) in
		image.draw(in: CGRect(origin: CGPoint(x: -image.size.width / 2, y: 0), size: image.size))
		return true
	})

	return scaledImage
}

func clickPanel() {
	LogFunc()

	if let image = imagePanel.contentImage {

		let image2 = doubleWidth(image)

		let imageMaterial = SCNMaterial()
		imageMaterial.diffuse.contents = image2
		imageMaterial.lightingModel = .constant
		imageMaterial.isDoubleSided = true

		let cylinderRadius: CGFloat = image.size.width * baseNodeScale
		let cylinder = SCNCylinder(radius: cylinderRadius, height: image.size.height * baseNodeScale)
		cylinder.materials = [imageMaterial, SCNMaterial.clear, SCNMaterial.clear]

		imagePanel.imageNode.eulerAngles.y

		imagePanel.animateToRotationRadians(imagePanel.eulerAngles.y + .pi / 2, withDuration: panelAnimationDuration / 2, completion: {

			imagePanel.imageNode.eulerAngles.y
			sceneView.scene?.rootNode.addChildNode(imagePanel.imageNode)
			imagePanel.imageNode.eulerAngles.y

			let initialScale = (imagePanel.originalPanelGeometry.height / cylinder.height) * baseNodeScale * imagePanel.scale.x
			imagePanel.imageNode.scale = SCNVector3(initialScale, initialScale, initialScale)
			imagePanel.imageNode.geometry = cylinder
//			imagePanel.imageNode.eulerAngles.y = -.pi

			imagePanel.imageNode.animateRotationByRadians((135 + 180) * .pi / 180, withDuration: panelAnimationDuration)
			imagePanel.imageNode.eulerAngles.y
			imagePanel.imageNode.animateToScale(SCNVector3Make(1, 1, 1), withDuration: panelAnimationDuration * 2)

			// since node is now rotated 90 deg, moving along -x axis brings it closer
			imagePanel.imageNode.animateToPosition(SCNVector3(0, 0, -5), withDuration: panelAnimationDuration, completion: {
				imagePanel.imageNode.eulerAngles.y
//				movePanelBack()
			})
		})
	}
}

func movePanelBack() {
	LogFunc()

	imagePanel.imageNode.animateRotationByRadians(.pi / 4, withDuration: panelAnimationDuration)
	imagePanel.imageNode.animateToPosition(originalImageNodePosition, withDuration: panelAnimationDuration)
	// scale along z faster to keep cylinder close to panel node
	imagePanel.imageNode.animateToScale(SCNVector3(0.2, 0.2, 0.05), withDuration: panelAnimationDuration, completion: {
		imagePanel.imageNode.animateToScale(SCNVector3(0.05, 0.05, 0.01), withDuration: panelAnimationDuration)
		imagePanel.animateRotationByRadians(.pi / 2, withDuration: panelAnimationDuration / 2, completion: {
			imagePanel.restoreGeometry()
			imagePanel.imageNode.scale = originalImageNodeScale
			imagePanel.imageNode.eulerAngles.y = 0
			imagePanel.animateRotationByRadians(.pi, withDuration: panelAnimationDuration, completion: {
//				clickPanel()
			})
		})
	})
}

if here {
	clickPanel()
}

PlaygroundPage.current.liveView = sceneView
