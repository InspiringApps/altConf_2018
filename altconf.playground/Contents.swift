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


//func appendImage(image: UIImage) {
//	LogMethod()
//
//	var size: CGFloat?
//	if (self.outputText.string.utf16Count > 0) {
//		size = self.outputText.attribute(NSFontAttributeName, atIndex:0, effectiveRange:nil)?.pointSize
//	}
//
//	if (size == nil) {
//		size = self.fontSize()
//	}
//
//	var imageAttachment: NSTextAttachment = NSTextAttachment()
//	imageAttachment.image = image
//	imageAttachment.bounds = CGRectMake(0, -2, size! + 2, size! + 2)
//	var imageAttributedString = NSAttributedString(attachment: imageAttachment)
//
//	self.outputText.appendAttributedString(imageAttributedString)
//
//	self.outputTextView.attributedText = self.outputText
//	self.hasImage = true
//	self.appendText(" ")
//	self.setCopyKeyAppearance()
//	self.adjustSize()
//}
//



let logo = Image.withName("altconf_logo")

let logoAttachmwnt = NSTextAttachment()
logoAttachmwnt.image = logo
logoAttachmwnt.bounds = CGRect(x: 0, y: -2, width: 14, height: 14)
let logoText = NSAttributedString(attachment: logoAttachmwnt)

let containerText = NSMutableAttributedString(string: "one")
containerText.append(logoText)
containerText.append(NSAttributedString(string: "two"))

let logoGeometry = SCNText(string: containerText, extrusionDepth: 2)
logoGeometry.materials = [SCNMaterial.green]

let logoNode = SCNNode(geometry: logoGeometry)
logoNode.scale = SCNVector3(0.1, 0.1, 0.1)

sceneView.scene?.rootNode.addChildNode(logoNode)
sceneView.debugOptions = .showBoundingBoxes




// measure { single, random, all }

// text { oneBottomLeft, oneCentered, varyLengthsCentered, varyLengthsBottomLeft, sphericalTitle, addBlueMaterial, addSomeGray }

// image { one, many, addMob }
// video { one, many }

