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

let panelBaseRadius: CGFloat = 1.0
let panelMidPoint: CGFloat = 0
let panelSpacingDegrees: CGFloat = 0

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

func degreesFromCenterForPanelIndex(_ index: Int) -> CGFloat {
	return ((CGFloat(index) - panelMidPoint) * panelSpacingDegrees)
}

func loopVideoSliceForNode(_ videoNode: VideoPanel) {
	LogFunc()

	guard let item = videoNode.videoPlayer.currentItem else {
		return
	}

	let fullDuration = item.duration
	let sliceStart = CMTimeMultiplyByFloat64(fullDuration, 0.25)
	let sliceEnd = CMTimeAdd(sliceStart, CMTime(seconds: 1, preferredTimescale: fullDuration.timescale))

	videoNode.videoObserver = videoNode.videoPlayer.addBoundaryTimeObserver(forTimes: [NSValue(time: sliceEnd)], queue: DispatchQueue.main) {
		LogFunc("sliceEnd")
		videoNode.videoPlayer.rate = -1
	}
	// reseting videoObserver like this works much better than setting both boundaries in one call (which doesn't work at all)
	videoNode.videoObserver = videoNode.videoPlayer.addBoundaryTimeObserver(forTimes: [NSValue(time: sliceStart)], queue: DispatchQueue.main) {
		LogFunc("sliceStart")
		videoNode.videoPlayer.rate = 1
	}

	videoNode.videoPlayer.seek(to: sliceStart)
	videoNode.videoPlayer.play()
}

let videoNode = VideoPanel(title: "title", videoFile: "vid1_trimmed.mov", index: 0)
videoNode.position = SCNVector3(0,0,0)
sceneView.scene?.rootNode.addChildNode(videoNode)

videoNode.videoObserver = videoNode.videoPlayer.addBoundaryTimeObserver(forTimes: [NSValue(time: CMTime(seconds: 0.25, preferredTimescale: 600))], queue: DispatchQueue.main) {
	if let observer = videoNode.videoObserver {
		videoNode.videoPlayer.removeTimeObserver(observer)
	}
	loopVideoSliceForNode(videoNode)
}
videoNode.videoPlayer.volume = 0
videoNode.videoPlayer.play()







// Demos.Measurement.DemoMode { single, random, all }

// Demos.Text.DemoMode 		{ oneBottomLeft, oneCentered, varyLengthsCentered, varyLengthsBottomLeft, sphericalTitle, addBlueMaterial, addSomeGray }

// Demos.Images.DemoMode { single, many }

