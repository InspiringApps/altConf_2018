//: A Cocoa based Playground to play with SceneKit

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
cameraNode.look(at: SCNVector3(x: 0, y: 0, z: 0))
sceneView.scene?.rootNode.addChildNode(cameraNode)

enum DemoDriver {
	case measure(mode: Demos.Measurement.DemoMode)
	case text(mode: Demos.Text.DemoMode)
	case image(mode: Demos.Images.DemoMode)
}

let currentDemo = DemoDriver.image(mode: .many)

switch currentDemo {
case .measure(let mode):
	cameraNode.position = SCNVector3(x: 0, y: 0, z: 15)
	Demos.Measurement.runwithView(sceneView, mode: mode)
case .text(let mode):
	cameraNode.position = SCNVector3(x: 0, y: 0, z: 15)
	Demos.Text.runwithView(sceneView, mode: mode)
case .image(let mode):
	cameraNode.position = SCNVector3(x: 0, y: 0, z: 10)
	let imageDemo = Demos.Images()
	imageDemo.runwithView(sceneView, mode: mode)
//	sceneView.debugOptions = .showBoundingBoxes
//	sceneView.hitTestNaive = false
}






PlaygroundPage.current.liveView = sceneView




// Demos.Measurement.DemoMode { single, random, all }

// Demos.Text.DemoMode 		{ oneBottomLeft, oneCentered, varyLengthsCentered, varyLengthsBottomLeft, sphericalTitle, addBlueMaterial, addSomeGray }

// Demos.Images.DemoMode { single, many }

