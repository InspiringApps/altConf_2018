import Foundation
import SceneKit

public class ARView: SCNView {

	var startTransform: SCNMatrix4?
	var rotatableNode: SCNNode?
	var rotationGesture: NSPanGestureRecognizer?
	var rotateNode = false {
		didSet {
			if rotateNode {
				backgroundColor = .clear
				allowsCameraControl = false
				rotationGesture?.isEnabled = true
			} else {
				backgroundColor = .lightGray
				allowsCameraControl = true
				rotationGesture?.isEnabled = false
			}
		}
	}

	let rootScene = SCNScene()

	public override init(frame frameRect: NSRect) {
		LogFunc()

		super.init(frame: frameRect)

		backgroundColor = .lightGray
		allowsCameraControl = true
		scene = rootScene
	}

	override init(frame: NSRect, options: [String : Any]? = nil) {
		super.init(frame: frame, options: options)
	}

	public required init?(coder decoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	public func makeRotatable(_ node: SCNNode) {
		LogFunc()

		rotatableNode = node

		if rotationGesture == nil {
			rotationGesture = NSPanGestureRecognizer(target: self, action: #selector(handleDrag(gesture:)))
			addGestureRecognizer(rotationGesture ?? NSPanGestureRecognizer() )

			let doubleTap = NSClickGestureRecognizer(target: self, action: #selector(handleDoubleTap(gesture:)))
			doubleTap.numberOfClicksRequired = 2
			addGestureRecognizer(doubleTap)
			rotateNode = true
		}
	}

	@objc
	func handleDrag(gesture: NSPanGestureRecognizer) {

		guard rotateNode, let node = rotatableNode else {
			return
		}

		switch gesture.state {
		case .possible:
			break
		case .began:
			LogFunc("began")
			// only allow setup if node is in the scene
			if rootScene.rootNode.hasChildNode(node) {
				startTransform = node.transform
			} else {
				startTransform = nil
			}
		case .changed:
			// don't attempt to rotate a node that is not in the scene
			guard let nodeTransform = startTransform else {
				return
			}

			let deltaPoint = gesture.translation(in: self)
			let horizontalMovePercentage = deltaPoint.x / frame.width
			let verticalMovePercentage = deltaPoint.y / frame.height

			let rotationAroundX = SCNMatrix4Rotate(nodeTransform, -verticalMovePercentage * .pi, 1, 0, 0)
			let rotationAroundY = SCNMatrix4Rotate(rotationAroundX, horizontalMovePercentage * .pi, 0, 1, 0)
			node.transform = rotationAroundY
		case .ended:
			LogFunc("ended")
		case .cancelled:
			break
		case .failed:
			break
		}

	}

	@objc
	func handleDoubleTap(gesture: NSClickGestureRecognizer) {
		LogFunc()
		rotateNode = !rotateNode
	}

}

