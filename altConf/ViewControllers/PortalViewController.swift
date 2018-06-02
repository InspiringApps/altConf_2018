//  altConf
//  Created by Erwin Mazariegos on 5/25/18 using Swift 4.0.
//  Copyright © 2018 Erwin. All rights reserved.

import UIKit
import SceneKit
import ARKit

class PortalViewController: UIViewController, ARSCNViewDelegate {

	@IBOutlet var sceneView: ARSCNView!

	override func viewDidLoad() {
		LogFunc()
		super.viewDidLoad()

		sceneView.delegate = self

		let scene = SCNScene(named: "portal.scn")!
		sceneView.scene = scene
	}

	override func viewWillAppear(_ animated: Bool) {
		LogFunc()
		super.viewWillAppear(animated)

		let configuration = ARWorldTrackingConfiguration()
		sceneView.session.run(configuration)
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

	// MARK: - ARSCNViewDelegate

	/*
	// Override to create and configure nodes for anchors added to the view's session.
	func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
		let node = SCNNode()

		return node
	}
	*/

	func session(_ session: ARSession, didFailWithError error: Error) {
		LogFunc()
	}

	func sessionWasInterrupted(_ session: ARSession) {
		LogFunc()
	}

	func sessionInterruptionEnded(_ session: ARSession) {
		LogFunc()
	}
}
