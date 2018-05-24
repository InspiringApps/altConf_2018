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


Demos.Images.runwithView(sceneView, mode: .many)


PlaygroundPage.current.liveView = sceneView
