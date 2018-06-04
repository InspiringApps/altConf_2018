//  altConf
//  Created by Erwin Mazariegos on 6/4/18 using Swift 4.0.
//  Copyright © 2018 Erwin. All rights reserved.

import Foundation
import SceneKit
import ARKit

class VideoBoxesViewController: UIViewController {

	@IBOutlet var sceneView: ARSCNView!

	let session = ARSession()

	var panelBaseRadius: Float = 0
	var panelMidPoint: Float = 0
	var panelSpacingDegrees: Float = 0

	override func viewDidLoad() {
		LogFunc()
		super.viewDidLoad()

		sceneView.scene = SCNScene()

		let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
		sceneView.addGestureRecognizer(tap)
	}

	override func viewWillAppear(_ animated: Bool) {
		LogFunc()
		super.viewWillAppear(animated)

		let configuration = ARWorldTrackingConfiguration()
		sceneView.session.run(configuration)

		addPanels()
	}

	override func viewWillDisappear(_ animated: Bool) {
		LogFunc()
		super.viewWillDisappear(animated)
		sceneView.session.pause()
	}

	override func didReceiveMemoryWarning() {
		LogFunc()
		super.didReceiveMemoryWarning()
	}

	@objc
	func handleTap(sender: UITapGestureRecognizer) {
		LogFunc()

		let tapPoint = sender.location(in: sceneView)
		let results = sceneView.hitTest(tapPoint, options: nil)

		var tappedPanel: VideoPanel?

		results.forEach({ hitResult in
			if let videoNode = hitResult.node.ancestorOfClass(VideoPanel.self) {
				tappedPanel = videoNode
			}
		})

		if let panel = tappedPanel {
			tapPanel(panel)
		}
	}

	func addPanels() {
		LogFunc()

		let videoMap = [
			("Urban Valley: Night", "vid1_trimmed.mov"),
			("Bridge Across", "vid2_trimmed.mov"),
			("Tentacles: Day", "vid3_trimmed.mov")
		]

		let minimumPanelRadius: Float = 1.0

		panelSpacingDegrees = 180.0 / Float(videoMap.count)
		panelMidPoint = 0.5 * Float(videoMap.count - 1)
		panelBaseRadius = max(minimumPanelRadius, Float(videoMap.count) * 1.6)

		for (index, map) in videoMap.enumerated() {
			let videoNode = VideoPanel(title: map.0, videoFile: map.1, index: index)

			let degreesFromCenter = degreesFromCenterForPanelIndex(index)
			videoNode.position = positionForDegreesFromCenter(degreesFromCenter, atRadius: panelBaseRadius)
			videoNode.eulerAngles.y = -degreesFromCenter * (.pi / 180.0)

			sceneView.scene.rootNode.addChildNode(videoNode)
		}

		sceneView.scene.isPaused = true	// prevent actions from running prematurely
	}

	func tapPanel(_ panel: VideoPanel) {
		LogFunc()
		// actions have been removed from the nodes,
		// we need to unpause the scene so we can run them here
		sceneView.scene.isPaused = false

		if panel.isOpen {
			panel.closeActions.forEach({ nodeAction in
				nodeAction.node.runAction(nodeAction.action)
			})
			panel.playbackLooped()
		} else {
			panel.openActions.forEach({ nodeAction in
				nodeAction.node.runAction(nodeAction.action)
			})
			panel.playbackNormal()
		}
		panel.isOpen = !panel.isOpen
	}

	func positionForDegreesFromCenter(_ degrees: Float, atRadius radius: Float, xOffset: Float = 0, yOffset: Float = 0) -> SCNVector3 {
		let radiansFromCenter = degrees * (.pi / 180.0)
		let x: Float = sin(radiansFromCenter) * radius
		let z: Float = cos(radiansFromCenter) * radius
		return SCNVector3(x + xOffset, yOffset, -z)
	}

	func positionForRadiansFromCenter(_ radians: Float, atRadius radius: Float, yOffset: Float = 0) -> SCNVector3 {
		let degrees = -radians * 180 / .pi
		return positionForDegreesFromCenter(degrees, atRadius: radius, yOffset:yOffset)
	}

	func degreesFromCenterForPanelIndex(_ index: Int) -> Float {
		return ((Float(index) - panelMidPoint) * panelSpacingDegrees)
	}

}

