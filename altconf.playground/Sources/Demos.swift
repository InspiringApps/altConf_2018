import Foundation
import SceneKit

public struct Demos {

	static let radius: CGFloat = 0.05

	public static func measurement(_ sceneView: ARView) {
		let start = SCNNode(geometry: SCNSphere(radius: radius))
		start.geometry?.materials = [SCNMaterial.black]
		start.position = SCNVector3(x: 0.5, y: 0.2, z: -1)
		sceneView.addNode(start)

		func addRulerTo(_ endPoint: SCNVector3) {

			let end = SCNNode(geometry: SCNSphere(radius: radius))
			end.geometry?.materials = [SCNMaterial.white]
			end.position = endPoint
			sceneView.addNode(end)

			let line = Ruler(startPosition: start.position, material: SCNMaterial.blue, radius: radius / 2)
			sceneView.addNode(line)
			line.measureTo(end.position)

			let pane = PictureNode(at: start.position)
			sceneView.addNode(pane)
			pane.followRuler(line)
			//	pane.showPivot()
			pane.showAxes()
		}

		let points = [
			SCNVector3(-2, 2, -3),
			SCNVector3(2, 2, -3),
			SCNVector3(-2, 2, 3),
			SCNVector3(2, -2, 1),
			SCNVector3(2, 2, 1),
			SCNVector3(-2, -2, 1)
		]

		//addRulerTo(points[1])

		//let point = points[Int(arc4random_uniform(UInt32(points.count - 1)))]
		//addRulerTo(point)

		points.forEach({ addRulerTo($0) })
	}



}
