//: A Cocoa based Playground to play with SceneKit

// portal w/ altconf logo inside
// panel to image morph

import AppKit
import PlaygroundSupport
import SceneKit
import SpriteKit
import AVFoundation

// create custom SCNView with default camera interactivity and optional rotatable node handling
let sceneView = ARView(frame: CGRect(x: 0, y: 0, width: 600, height: 1000))

// add own camera to replace default camera, for better control of initial view
let cameraNode = SCNNode()
cameraNode.camera = SCNCamera()
cameraNode.look(at: SCNVector3(x: 0, y: 0, z: 0))
sceneView.scene?.rootNode.addChildNode(cameraNode)

PlaygroundPage.current.liveView = sceneView

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
	cameraNode.position = SCNVector3(x: 0, y: 0, z: 10)
}




// measure { single, random, all }
// text { oneBottomLeft, oneCentered, varyLengthsCentered, varyLengthsBottomLeft, sphericalTitle, addBlueMaterial, addSomeGray }
// image { one, many, addMob }
// video { one, many }

