// Erwin Mazariegos
// Altconf 2018: AR+SceneKit Tips & Tricks

import Foundation
import SceneKit
import SpriteKit
import AVFoundation

extension Demos {

	public class Video {

		public enum DemoMode {
			case one, many
		}

		var panelBaseRadius: CGFloat = 1.0
		var panelMidPoint: CGFloat = 0
		var panelSpacingDegrees: CGFloat = 0

		var clickGesture: NSClickGestureRecognizer?
		var demoSceneView: ARView?

		public init() {
			LogFunc()
		}

		public func runwithView(_ sceneView: ARView, mode: DemoMode) {
			LogFunc()

			let videoMap = [
				("Urban Valley: Night", "vid1_trimmed.mov"),
				("Bridge Across", "vid2_trimmed.mov"),
				("Tentacles: Day", "vid3_trimmed.mov")
			]

			let minimumPanelRadius: CGFloat = 1.0

			panelSpacingDegrees = 180.0 / CGFloat(videoMap.count)
			panelMidPoint = 0.5 * CGFloat(videoMap.count - 1)
			panelBaseRadius = max(minimumPanelRadius, CGFloat(videoMap.count) * 1.6)

			switch mode {
			case .one:
				let videoNode = VideoPanel(title: videoMap[0].0, videoFile: videoMap[0].1, index: 0)
				videoNode.position = positionForDegreesFromCenter(0, atRadius: panelBaseRadius)
				sceneView.scene?.rootNode.addChildNode(videoNode)
				sceneView.makeRotatable(videoNode)
			case .many:
				for (index, map) in videoMap.enumerated() {
					let videoNode = VideoPanel(title: map.0, videoFile: map.1, index: index)

					let degreesFromCenter = degreesFromCenterForPanelIndex(index)
					videoNode.position = positionForDegreesFromCenter(degreesFromCenter, atRadius: panelBaseRadius)
					videoNode.eulerAngles.y = -degreesFromCenter * (.pi / 180.0)

					sceneView.scene?.rootNode.addChildNode(videoNode)
				}
			}

			if clickGesture == nil {	// ensure click gesture is only added once
				clickGesture = NSClickGestureRecognizer(target: sceneView, action: #selector(sceneView.handleClick(gesture:)))
				sceneView.addGestureRecognizer(clickGesture ?? NSClickGestureRecognizer() )

				sceneView.clickAction = { (results) in
					self.processHitTestResults(results)
				}
			}

			demoSceneView = sceneView
			sceneView.scene?.isPaused = true		// prevent actions from running prematurely
		}

		public func processHitTestResults(_ results: [SCNHitTestResult]) {
			LogFunc()

			var tappedPanel: VideoPanel?

			results.forEach({ hitResult in
				if let videoNode = hitResult.node.ancestorOfClass(VideoPanel.self) {
					tappedPanel = videoNode
				}
			})

			if let panel = tappedPanel {
				clickPanel(panel)
			}
		}

		public func clickPanel(_ panel: VideoPanel) {
			LogFunc()

			// actions have been removed from the nodes,
			// we need to unpause the scene so we can run them here
			demoSceneView?.scene?.isPaused = false

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

	}
}


