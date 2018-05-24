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

//let imageDemo = Demos.Images()
//imageDemo.runwithView(sceneView, mode: .many)

let originalPosition = SCNVector3(0, 0, -10)
let image = Image.withName("landscape1.jpg")
let imagePanel = ImagePanel(title: "Testing Stuff", image: image, index: 0)
imagePanel.position = originalPosition
sceneView.scene?.rootNode.addChildNode(imagePanel)

var originalImageNodeScale = imagePanel.imageNode.scale

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

		imagePanel.animateToRotationRadians(imagePanel.eulerAngles.y + .pi / 2, withDuration: panelAnimationDuration / 2, completion: {
			let initialScale = (imagePanel.originalPanelGeometry.height / cylinder.height) * baseNodeScale
			imagePanel.imageNode.scale = SCNVector3(initialScale, initialScale, initialScale)
			imagePanel.imageNode.geometry = cylinder
			imagePanel.imageNode.eulerAngles.y = -.pi

			imagePanel.imageNode.animateToRotationRadians(-135 * .pi / 180, withDuration: panelAnimationDuration)
			imagePanel.imageNode.animateToScale(SCNVector3Make(1, 1, 1), withDuration: panelAnimationDuration)

			// since node is now rotated 90 deg, moving along -x axis brings it closer
			imagePanel.imageNode.animateToPosition(SCNVector3(-25, 0, 0), withDuration: panelAnimationDuration)
		})
	}
}

func movePanelBack() {
	LogFunc()

	let panelDegrees: CGFloat = 0

	imagePanel.animateToPosition(originalPosition, withDuration: panelAnimationDuration)

	imagePanel.animateToRotationRadians(imagePanel.eulerAngles.y - .pi / 2, withDuration: panelAnimationDuration, completion: {
		imagePanel.imageNode.scale = originalImageNodeScale
		imagePanel.restoreGeometry()
		imagePanel.animateToRotationRadians(-panelDegrees * (.pi / 180.0), withDuration: panelAnimationDuration)
	})

}


clickPanel()

//let clickGesture = NSClickGestureRecognizer(target: t, action: #selector(t.clickPanel()))
//sceneView.addGestureRecognizer(clickGesture)


PlaygroundPage.current.liveView = sceneView
