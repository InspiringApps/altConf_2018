//: A Cocoa based Playground to present user interface

//: text node, pivot point, alignment utilities
// spritekit video & test
// portal w/ altconf logo inside
// panel to image morph
// animated people in audience
// gestures to rotate scene


import AppKit
import PlaygroundSupport
import SceneKit
import SpriteKit

let sceneView = ARView(frame: CGRect(x: 0, y: 0, width: 600, height: 1000))

let cameraNode = SCNNode()
cameraNode.camera = SCNCamera()
cameraNode.position = SCNVector3(x: 1, y: 5, z: 12)
cameraNode.look(at: SCNVector3(x: 0, y: 0, z: 0))
sceneView.scene?.rootNode.addChildNode(cameraNode)

//Demos.measurement(sceneView)

let text = "SceneKit can lay out a body of text to fit within a rectangular area. To do this, you must first use this property to define the area for text layout as a rectangle in the x- and y-axis dimensions of the text object’s local coordinate system. "

func addNodeForText(_ text: String, withPivotCorner corner: RectCorner) {

	let panelGeometry = SCNBox(width: 20, height: 30, length: 1, chamferRadius: 3)
	panelGeometry.materials = [SCNMaterial.black]

	let panelNode = SCNNode(geometry: panelGeometry)
	panelNode.position = SCNVector3(0, 0, -1)
	panelNode.scale = SCNVector3(0.2, 0.2, 0.2)

	let tagText = SCNText(string: text, extrusionDepth: 2)
	tagText.isWrapped = true
	tagText.containerFrame = CGRect(origin: .zero, size: CGSize(width: panelGeometry.width, height: panelGeometry.height))
	tagText.font = NSFont.systemFont(ofSize: 2)
	tagText.materials = [SCNMaterial.white, SCNMaterial.blue, SCNMaterial.gray]

	let tagTextNode = SCNNode(geometry: tagText)
	tagTextNode.pivotAtCorner(corner, showPivotWithColor: .green)
	tagTextNode.position = SCNVector3(0, 0, 2)
	panelNode.addChildNode(tagTextNode)

	sceneView.addNode(panelNode)
}

addNodeForText(String(text.prefix(150)), withPivotCorner: .topLeft)




PlaygroundPage.current.liveView = sceneView
