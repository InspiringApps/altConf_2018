import Foundation
import SceneKit

public class ARView: SCNView {

	let containerNode = SCNNode()
	let rootScene = SCNScene()

	var startPoint = CGPoint.zero
	var startTransform = SCNMatrix4Identity

	public override init(frame frameRect: NSRect) {
		super.init(frame: frameRect)

		backgroundColor = NSColor.lightGray
		autoenablesDefaultLighting = false
//		debugOptions = .showBoundingBoxes

		addGestureRecognizer(NSPanGestureRecognizer(target: self, action: #selector(handleDrag(gesture:))))

		scene = rootScene
		scene?.rootNode.addChildNode(containerNode)
	}

	override init(frame: NSRect, options: [String : Any]? = nil) {
		super.init(frame: frame, options: options)
	}

	public required init?(coder decoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	public func addNode(_ node: SCNNode) {
		containerNode.addChildNode(node)
	}

	@objc
	func handleDrag(gesture: NSPanGestureRecognizer) {
		switch gesture.state {
		case .possible:
			print("gesture possible")
		case .began:
			print("gesture began")
			startPoint = gesture.location(in: self)
			startTransform = containerNode.transform
		case .changed:
			let newPoint = gesture.location(in: self)
			let deltaX = newPoint.x - startPoint.x
			let deltaY = newPoint.y - startPoint.y

			let horizontalMovePercentage = deltaX / frame.width
			let verticalMovePercentage = deltaY / frame.height

			let rotateX = SCNMatrix4Rotate(startTransform, -verticalMovePercentage * .pi, 1, 0, 0)
			let rotateY = SCNMatrix4Rotate(rotateX, horizontalMovePercentage * .pi, 0, 1, 0)
			containerNode.transform = rotateY
		case .ended:
			print("gesture ended")
		case .cancelled:
			print("gesture cancelled")
		case .failed:
			print("gesture failed")
		}

	}

}

