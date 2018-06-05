// Note: for demo purposes, this main content page only sets up and chooses which demo to run.
// All functional code is in the "Sources" subfolder.
// In actual development, you want to minimize or eliminate the sources module, and do as much on this page as possible.

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

/*   Begin cheat sheet
// measure { one, random, many }
// text { oneBottomLeft, oneCentered, manyCentered, manyBottomLeft, sphericalTitle, addBlueMaterial, addSomeGray }
// image { one, many, addMob }
// video { one, many }
*/ /* end cheat sheet */

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
	cameraNode.position = SCNVector3(x: 0, y: 0, z: 17)
	Demos.Measurement.runwithView(sceneView, mode: mode)
case .text(let mode):
	cameraNode.position = SCNVector3(x: 0, y: 0, z: 15)
	Demos.Text.runwithView(sceneView, mode: mode)
case .image(let mode):
	cameraNode.position = SCNVector3(x: 0, y: 0, z: 10)
	let imageDemo = Demos.Images()
	imageDemo.runwithView(sceneView, mode: mode)
//	sceneView.debugOptions = .showBoundingBoxes
	imageDemo.hitTestNaive = false
case .video(let mode):
	cameraNode.position = SCNVector3(x: 0, y: 0, z: 3)
	let videoDemo = Demos.Video()
	videoDemo.runwithView(sceneView, mode: mode)
case .none:
	cameraNode.position = SCNVector3(x: 0, y: 0, z: 10)







}

cameraNode.look(at: SCNVector3(x: 0, y: 0, z: 0))


