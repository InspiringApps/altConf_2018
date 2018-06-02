//  altConf
//  Created by Erwin Mazariegos on 6/2/18.
//  Copyright (c) 2018 Erwin. All rights reserved.

import Foundation
import SceneKit

class Ruler: SCNNode {

	enum MeasurementMode {
		case horizontal, vertical
	}

	/// length of ruler in meters
	var measurement: CGFloat {
		return capsule.height
	}

	var measurementMode = MeasurementMode.horizontal

	private var startPoint = SCNVector3Zero
	private var endPoint = SCNVector3Zero
	private let capsule = SCNCapsule()
	private let radius: CGFloat = 0.005
	private let rulerMaterial = SCNMaterial()

	override init() {
		rulerMaterial.diffuse.contents = UIColor.green
		capsule.capRadius = radius
		capsule.materials = [rulerMaterial]
		super.init()
		geometry = capsule
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	func resetAt(_ newPosition: SCNVector3) {
		LogFunc()
		startPoint = newPosition
		endPoint = newPosition
		position = startPoint
		measureTo(endPoint)
	}

	func measureTo(_ end: SCNVector3) {

		let constrainedEnd: SCNVector3
		switch measurementMode {
		case .horizontal:
			constrainedEnd = SCNVector3(end.x, end.y, end.z)
		case .vertical:
			constrainedEnd = SCNVector3(startPoint.x, end.y, end.z)
		}

		endPoint = constrainedEnd
		let deltaVector = SCNVector3(endPoint.x - startPoint.x, endPoint.y - startPoint.y, endPoint.z - startPoint.z)
		let distance = Float(deltaVector.length())
		capsule.height = CGFloat(distance)
		pivot = SCNMatrix4Translate(SCNMatrix4Identity, 0, -distance / 2, 0)

		let yLength = sqrt(Float(deltaVector.x * deltaVector.x) + Float(deltaVector.z * deltaVector.z))
		let xAngle = deltaVector.y < 0 ? .pi - asinf(yLength/distance) : asinf(yLength/distance)
		let pitch = deltaVector.z == 0 ? xAngle : deltaVector.z < 0 ? -xAngle : xAngle

		var yaw: Float = 0
		if deltaVector.x != 0 || deltaVector.z != 0 {
			let inner = deltaVector.x / (distance * sin(pitch))
			if inner > 1 || inner < -1 {
				yaw = .pi / 2
			} else {
				yaw = asinf(inner)
			}
		}

		eulerAngles.x = pitch
		eulerAngles.y = yaw
		eulerAngles.z = 0
	}
}

func + (left: SCNVector3, right: SCNVector3) -> SCNVector3 {
	return SCNVector3Make(left.x + right.x, left.y + right.y, left.z + right.z)
}

func - (left: SCNVector3, right: SCNVector3) -> SCNVector3 {
	return SCNVector3Make(left.x - right.x, left.y - right.y, left.z - right.z)
}
