/*









	AR + SceneKit Tips and Tricks


   github.com/InspiringApps/altConf_2018













*/



// Note: for demo purposes, this main content page only sets up and chooses which demo to run.
// All functional code is in the "Sources" subfolder.
// In actual development, you want to minimize or eliminate the sources module, and do as much on this page as possible.

import PlaygroundSupport
import SceneKit
import SpriteKit
import AVFoundation


// create custom SCNView with default camera interactivity and optional rotatable node handlingS
let sceneView = ARView(frame: CGRect(x: 0, y: 0, width: 600, height: 1000))
PlaygroundPage.current.liveView = sceneView

//// add own camera to replace default camera, for better control of initial view
let cameraNode = SCNNode()
cameraNode.camera = SCNCamera()
sceneView.scene?.rootNode.addChildNode(cameraNode)

public enum DemoDriver {
	case measure(mode: Demos.Measurement.DemoMode)
	case text(mode: Demos.Text.DemoMode)
	case image(mode: Demos.Images.DemoMode)
	case video(mode: Demos.Video.DemoMode)
	case none
}

/*   Begin cheat sheet
measure { one, random, many }
text { oneBottomLeft, oneCentered, manyCentered, manyBottomLeft, sphericalTitle, addBlueMaterial, addSomeGray }
image { one, many, addMob }
video { one, many }
*/ // end cheat sheet

let currentDemo = DemoDriver.text(mode: .manyCentered)

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

	let node = SCNNode()
	sceneView.scene?.rootNode.addChildNode(node)

	let box = SCNBox(width: 2, height: 2, length: 2, chamferRadius: 0.25)
	node.geometry = box

	box.materials = [
		SCNMaterial.green,
		SCNMaterial.yellow,
		SCNMaterial.blue
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


}

cameraNode.look(at: SCNVector3(x: 0, y: 0, z: 0))


