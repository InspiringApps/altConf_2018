// Erwin Mazariegos
// Altconf 2018: AR+SceneKit Tips & Tricks

import Foundation
import SceneKit
import SpriteKit
import AVFoundation

extension Demos {

	public class Video {

		public enum DemoMode {
			case temp
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
				("Flow Valley - Night", "vid1_trimmed.mov"),
				("Across", "vid2_trimmed.mov"),
				("Flow - Day", "vid3_trimmed.mov")
			]

			let minimumPanelRadius: CGFloat = 1.0

			panelSpacingDegrees = 180.0 / CGFloat(videoMap.count)
			panelMidPoint = 0.5 * CGFloat(videoMap.count - 1)
			panelBaseRadius = max(minimumPanelRadius, CGFloat(videoMap.count) * 1.4)

			for (index, map) in videoMap.enumerated() {
				let videoNode = VideoPanel(title: map.0, videoFile: map.1, index: index)

				let degreesFromCenter = degreesFromCenterForPanelIndex(index)
				videoNode.position = positionForDegreesFromCenter(degreesFromCenter, atRadius: panelBaseRadius)
				videoNode.eulerAngles.y = -degreesFromCenter * (.pi / 180.0)

				sceneView.scene?.rootNode.addChildNode(videoNode)

				videoNode.videoObserver = videoNode.videoPlayer.addBoundaryTimeObserver(forTimes: [NSValue(time: CMTime(seconds: 0.25, preferredTimescale: 600))], queue: DispatchQueue.main) {
					if let observer = videoNode.videoObserver {
						videoNode.videoPlayer.removeTimeObserver(observer)
					}
					self.loopVideoSliceForNode(videoNode)
				}
				videoNode.videoPlayer.volume = 0
				videoNode.videoPlayer.play()
			}

			//			switch mode {
			//			case .oneCentered:
			//
			//			case .oneTopLeft:
			//
			//			case .varyLengthsCentered:
			//
			//			case .varyLengthsBottomLeft:
			//
			//			case .sphericalTitle:
			//
			//			}

			if clickGesture == nil {
				clickGesture = NSClickGestureRecognizer(target: sceneView, action: #selector(sceneView.handleClick(gesture:)))
				sceneView.addGestureRecognizer(clickGesture ?? NSClickGestureRecognizer() )

				sceneView.clickAction = { (results) in
					self.processHitTestResults(results)
				}
			}

			demoSceneView = sceneView
			sceneView.scene?.isPaused = true
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
				videoNode.videoPlayer.rate = -1
			}
			// reseting videoObserver like this works much better than setting both boundaries in one call (which doesn't work at all)
			videoNode.videoObserver = videoNode.videoPlayer.addBoundaryTimeObserver(forTimes: [NSValue(time: sliceStart)], queue: DispatchQueue.main) {
				videoNode.videoPlayer.rate = 1
			}

			videoNode.videoPlayer.seek(to: sliceStart)
			videoNode.videoPlayer.play()
		}

		public func processHitTestResults(_ results: [SCNHitTestResult]) {
			LogFunc()

			var tappedPanel: VideoPanel?

			results.forEach({ hitResult in
				if let geometry = hitResult.node.geometry,
					let parent = hitResult.node.parent?.parent as? VideoPanel {
					if let _ = geometry as? SCNPlane {
						tappedPanel = parent
					}
				}
			})

			if let panel = tappedPanel {
				clickPanel(panel)
			}
		}

		public func clickPanel(_ panel: VideoPanel) {
			LogFunc()

			if let scene = demoSceneView?.scene {
				scene.setAttribute(1.0, forKey: "\(SCNScene.Attribute.endTime)")
				scene.isPaused = false
			}
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


