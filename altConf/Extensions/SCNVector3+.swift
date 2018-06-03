// Erwin Mazariegos
// Altconf 2018: AR+SceneKit Tips & Tricks

import Foundation
import SceneKit


extension SCNVector3 {

	public func distanceTo(_ to: SCNVector3) -> CGFloat {
		let x = self.x - to.x
		let y = self.y - to.y
		let z = self.z - to.z
		return CGFloat(sqrt( (x * x) + (y * y) + (z * z) ))
	}

	public func length() -> CGFloat {
		return CGFloat(sqrt( (x * x) + (y * y) + (z * z) ))
	}

	public init(transform: SCNMatrix4) {
		self = SCNVector3()
		x = transform.m41
		y = transform.m42
		z = transform.m43
	}

	public init(worldTransform: matrix_float4x4) {
		let matrix4 = SCNMatrix4(worldTransform)
		self.init(transform: matrix4)
	}
}

extension SCNVector3: Equatable {

	public static func ==(lhs: SCNVector3, rhs: SCNVector3) -> Bool {
		return SCNVector3EqualToVector3(lhs, rhs)
	}

}


func + (left: SCNVector3, right: SCNVector3) -> SCNVector3 {
	return SCNVector3Make(left.x + right.x, left.y + right.y, left.z + right.z)
}

func - (left: SCNVector3, right: SCNVector3) -> SCNVector3 {
	return SCNVector3Make(left.x - right.x, left.y - right.y, left.z - right.z)
}
