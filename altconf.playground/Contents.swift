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

Demos.Images.runwithView(sceneView, mode: .single)

PlaygroundPage.current.liveView = sceneView
