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
}

