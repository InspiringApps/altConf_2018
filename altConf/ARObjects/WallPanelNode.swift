//  altConf
//  Created by Erwin Mazariegos on 6/2/18.
//  Copyright (c) 2018 Erwin. All rights reserved.

import Foundation
import ARKit


class WallPanelNode: SCNNode {

	private let pane = SCNPlane()
	private var originalPosition = SCNVector3Zero

	init(at placement: SCNVector3) {
		super.init()

		let photo = UIImage(named: "landscape1")
		let material = SCNMaterial()
		material.diffuse.contents = photo
		material.isDoubleSided = true

		pane.materials = [material]
		pane.height = 8
		pane.width = 2

		originalPosition = placement

		geometry = pane
		pivot = SCNMatrix4Translate(SCNMatrix4Identity, Float(-pane.width / 2), Float(-pane.height / 2), 0)
		position = placement
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	func followRuler(_ ruler: Ruler) {
//		LogFunc()
		pane.width = ruler.measurement
		pivot = SCNMatrix4Translate(SCNMatrix4Identity, Float(-pane.width / 2), Float(-pane.height / 2), 0)

		let yDegrees = ruler.rotation.x < 0 ? .pi / 2 : -Float.pi / 2

		eulerAngles.x = .pi
		eulerAngles.z = -.pi
		eulerAngles.y = -ruler.eulerAngles.y + yDegrees
		position = originalPosition
	}

}
