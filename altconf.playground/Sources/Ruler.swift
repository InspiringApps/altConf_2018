import Foundation
import SceneKit


public class Ruler: SCNNode {

	private let capsule = SCNCapsule()

	private var startPoint = SCNVector3Zero
	private var endPoint = SCNVector3Zero

	public init(startPosition: SCNVector3, material: SCNMaterial, radius: CGFloat = 0.15) {
		super.init()
		startPoint = startPosition
		capsule.capRadius = radius
		capsule.materials = [material]
		geometry = capsule
		position = startPoint
	}

	public override init() {
		super.init()
	}

	public required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}

	public var measurement: CGFloat {
		return capsule.height
	}

	public func measureTo(_ end: SCNVector3) {
		endPoint = end
		let deltaVector = SCNVector3(endPoint.x - startPoint.x, endPoint.y - startPoint.y, endPoint.z - startPoint.z)
		let distance = deltaVector.length()
		capsule.height = distance
		pivot = SCNMatrix4Translate(SCNMatrix4Identity, 0, -capsule.height / 2, 0)

		let yLength = sqrt(CGFloat(deltaVector.x * deltaVector.x) + CGFloat(deltaVector.z * deltaVector.z))
		let pitchB = deltaVector.y < 0 ? .pi - asin(yLength/distance) : asin(yLength/distance)
		let pitch = deltaVector.z == 0 ? pitchB : deltaVector.z < 0 ? -pitchB : pitchB

		var yaw: CGFloat = 0
		if deltaVector.x != 0 || deltaVector.z != 0 {
			let inner = deltaVector.x / (distance * sin(pitch))
			if inner > 1 || inner < -1 {
				yaw = .pi / 2
			} else {
				yaw = asin(inner)
			}
		}

		eulerAngles.x = pitch
		eulerAngles.y = yaw
		eulerAngles.z = 0
	}
}

