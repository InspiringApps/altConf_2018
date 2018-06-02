//: A Cocoa based Playground to play with SceneKit

// panel to image morph

import AppKit
import PlaygroundSupport
import SceneKit
import SpriteKit
import AVFoundation

// create custom SCNView with default camera interactivity and optional rotatable node handling
let sceneView = ARView(frame: CGRect(x: 0, y: 0, width: 600, height: 1000))
PlaygroundPage.current.liveView = sceneView

// add own camera to replace default camera, for better control of initial view
let cameraNode = SCNNode()
cameraNode.camera = SCNCamera()
sceneView.scene?.rootNode.addChildNode(cameraNode)


enum DemoDriver {
	case measure(mode: Demos.Measurement.DemoMode)
	case text(mode: Demos.Text.DemoMode)
	case image(mode: Demos.Images.DemoMode)
	case video(mode: Demos.Video.DemoMode)
	case none
}

let currentDemo = DemoDriver.none

switch currentDemo {
case .measure(let mode):
	sceneView.debugOptions = .showCameras
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
//	imageDemo.hitTestNaive = false
case .video(let mode):
	cameraNode.position = SCNVector3(x: 0, y: 0, z: 10)
	let videoDemo = Demos.Video()
	videoDemo.runwithView(sceneView, mode: mode)
case .none:
	cameraNode.position = SCNVector3(x: 0, y: 10, z: 10)
}

cameraNode.look(at: SCNVector3(x: 0, y: 0, z: 0))

let node = SCNNode()
sceneView.scene?.rootNode.addChildNode(node)

let box = SCNBox(width: 2, height: 2, length: 1, chamferRadius: 0.25)
node.geometry = box

box.materials = [
	SCNMaterial.green,
	SCNMaterial.red,
	SCNMaterial.yellow,
	SCNMaterial.black
]

let ball = SCNNode(geometry: SCNSphere(radius: 1))
ball.geometry?.materials = [SCNMaterial.blue]
ball.position = SCNVector3(1, 1, -1)
sceneView.scene?.rootNode.addChildNode(ball)

let ball2 = SCNNode(geometry: SCNSphere(radius: 0.5))
ball2.geometry?.materials = [SCNMaterial.white]
ball2.position = SCNVector3(1, 2, -2)
sceneView.scene?.rootNode.addChildNode(ball2)

let container = SCNNode()
container.addChildNode(node)
container.addChildNode(ball)
sceneView.scene?.rootNode.addChildNode(container)

sceneView.debugOptions = [.showCameras, .showBoundingBoxes]

sceneView.makeRotatable(container)

/*
SCNPlane, SCNBox, SCNSphere, SCNPyramid, SCNCone, SCNCylinder, SCNCapsule, SCNTube, SCNTorus
SCNText, SCNShape
*/

// measure { single, random, all }
// text { oneBottomLeft, oneCentered, varyLengthsCentered, varyLengthsBottomLeft, sphericalTitle, addBlueMaterial, addSomeGray }
// image { one, many, addMob }
// video { one, many }

