//  altConf
//  Created by Erwin Mazariegos on 6/2/18.
//  Copyright (c) 2018 Erwin. All rights reserved.

import UIKit
import SceneKit
import ARKit

class MeasuringViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {

	@IBOutlet var sceneView: ARSCNView!

	@IBOutlet weak var instructionsLabel: UILabel!
	@IBOutlet weak var totalWidthLabel: UILabel!
	@IBOutlet weak var statusLabel: UILabel!

	@IBAction func reset(_ sender: UIButton) {
		LogFunc()

		let alert = UIAlertController(title: "Reset?", message: "Remove wall panel and reset ruler?", preferredStyle: .alert)
		let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
			alert.dismiss(animated: true, completion: nil)
		}

		let ok = UIAlertAction(title: "Reset", style: .destructive) { (action) in
			self.resetValues()
		}
		alert.addAction(cancel)
		alert.addAction(ok)
		present(alert, animated: true, completion: nil)
	}

	let session = ARSession()
	let ruler = Ruler()

	var measuring = false

	var panels = [WallPanelNode]()
	var currentPanel: WallPanelNode?
	var currentSegmentLength = 0.0
	var segmentStartValue = SCNVector3Zero

	let resultTypes: ARHitTestResult.ResultType = [.estimatedHorizontalPlane, .estimatedVerticalPlane]
	var rulerResultType: ARHitTestResult.ResultType?

	override func viewDidLoad() {
		LogFunc()
		super.viewDidLoad()

		sceneView.delegate = self
		sceneView.session.delegate = self
		sceneView.debugOptions = ARSCNDebugOptions.showFeaturePoints

		let scene = SCNScene()
		sceneView.scene = scene
		sceneView.scene.rootNode.addChildNode(ruler)
		resetValues()

		let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
		sceneView.addGestureRecognizer(tap)
	}

	override func viewWillAppear(_ animated: Bool) {
		LogFunc()
		super.viewWillAppear(animated)

		statusLabel.alpha = 0

		let configuration = ARWorldTrackingConfiguration()
		configuration.planeDetection = .vertical

		sceneView.session.run(configuration)
//		turnFlashOn()
	}

	override func viewWillDisappear(_ animated: Bool) {
		LogFunc()
		super.viewWillDisappear(animated)
		resetValues()
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
		let planeTestResults = sceneView.hitTest(tapPoint, types: resultTypes)

		if planeTestResults.isNotEmpty {
			measuring = !measuring
		}

		planeTestResults.forEach({ result in

			if measuring {
				if rulerResultType == nil {
					instructionsLabel.text = "Tap to set new segment"
					segmentStartValue = SCNVector3(worldTransform: result.worldTransform)
					ruler.resetAt(segmentStartValue)
					rulerResultType = result.type
					currentSegmentLength = 2

					let paneNode = WallPanelNode(at: segmentStartValue)
					sceneView.scene.rootNode.addChildNode(paneNode)
					panels.append(paneNode)
					currentPanel = paneNode
				}
			} else {
				if result.type == rulerResultType {
					instructionsLabel.text = "Tap for new segment"
					ruler.measureTo(SCNVector3(worldTransform: result.worldTransform))
					trackMovementToScreenPoint(tapPoint)

					showStatus("Measured length: \(ruler.lengthInUnit(.feet))")
					totalWidthLabel.text = ruler.lengthInUnit(.feet)
					currentSegmentLength = 0
					currentPanel = nil
				}
			}
		})
	}

	func resetValues() {
		LogFunc()
		segmentStartValue = SCNVector3Zero
		currentSegmentLength = 0

		panels.forEach({ $0.removeFromParentNode() })
		panels.removeAll()

		rulerResultType = nil
		currentPanel = nil

		ruler.resetAt(segmentStartValue)
		instructionsLabel.text = "Tap for new segment"
		totalWidthLabel.text = ruler.lengthInUnit(.feet)
	}

	func session(_ session: ARSession, didUpdate frame: ARFrame) {
		let centerPoint = CGPoint(x: view.frame.midX, y: view.frame.midY)
		trackMovementToScreenPoint(centerPoint)
	}

	func trackMovementToScreenPoint(_ point: CGPoint) {
		guard let paneNode = currentPanel else {
			return
		}

		let planeTestResults = sceneView.hitTest(point, types: resultTypes)

		planeTestResults.forEach({ result in
			if result.type == rulerResultType {
				ruler.measureTo(SCNVector3(worldTransform: result.worldTransform))
				paneNode.followRuler(ruler)
			}
		})
	}

	func showStatus(_ text: String) {
		LogFunc()

		statusLabel.text = text

		UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseIn, animations: {
			self.statusLabel.alpha = 1
		}) { (completed) in
			UIView.animate(withDuration: 0.3, delay: 4.0, options: .curveEaseIn, animations: {
				self.statusLabel.alpha = 0
			}) { (completed) in
			}
		}
	}

	func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
		LogFunc()

		let state: String

		switch(camera.trackingState) {
		case .notAvailable:
			state = "TRACKING: Unavailable"
		case .normal:
			state = "TRACKING: Normal"
		case .limited(let reason):
			switch reason {
			case .excessiveMotion:
				state = "TRACKING: LIMITED - Too much camera movement"
			case .insufficientFeatures:
				state = "TRACKING: LIMITED - Not enough surface detail"
			case .initializing:
				state = "TRACKING: Initializing"
			case .relocalizing:
				state = "TRACKING: Relocalizing"
			}
		}
		showStatus(state)
	}

	func session(_ session: ARSession, didFailWithError error: Error) {	LogFunc()	}
	func sessionWasInterrupted(_ session: ARSession) 		{	LogFunc()	}
	func sessionInterruptionEnded(_ session: ARSession) 	{	LogFunc()	}

	func turnFlashOn() {
		LogFunc()
		if let avDevice = AVCaptureDevice.default(for: AVMediaType.video) {
			if avDevice.hasTorch {
				do {
					try avDevice.lockForConfiguration()
				} catch {
					print(error)
				}

				if avDevice.isTorchActive {
					avDevice.torchMode = AVCaptureDevice.TorchMode.off
				} else {
					do {
						try avDevice.setTorchModeOn(level: 1.0)
					} catch {
						print(error)
					}
				}
				avDevice.unlockForConfiguration()
			}
		}
	}


}


