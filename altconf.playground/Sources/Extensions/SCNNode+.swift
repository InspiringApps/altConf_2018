import Foundation
import SceneKit

#if os(OSX)
	public enum NSRectCorner { case allCorners, topLeft, topRight, bottomLeft, bottomRight, other	}
	public typealias RectCorner = NSRectCorner
#else
	public typealias RectCorner = UIRectCorner
#endif

extension SCNNode {

	public func animateToPosition(_ position: SCNVector3, withDuration duration: TimeInterval, completion: (() -> Void)? = nil) {
		let animation = CABasicAnimation(keyPath: "position")
		animation.fromValue = self.position
		animation.toValue = position
		animation.duration = duration
		self.addAnimation(animation, forKey: "node move")
		self.position = position

		DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + duration) {
			completion?()
		}
	}

	/// animates to a rotation angle around the Y axis
	public func animateToRotationRadians(_ angle: CGFloat, withDuration duration: TimeInterval, completion: (() -> Void)? = nil) {
		let animation = CABasicAnimation(keyPath: "eulerAngles.y")
		animation.fromValue = self.eulerAngles.y
		animation.toValue = angle
		animation.duration = duration
		self.addAnimation(animation, forKey: "node rotate")
		self.eulerAngles.y = angle

		DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + duration) {
			completion?()
		}
	}

	public func animateToScale(_ scale: SCNVector3, withDuration duration: TimeInterval, completion: (() -> Void)? = nil) {
		let animation = CABasicAnimation(keyPath: "scale")
		animation.fromValue = self.scale
		animation.toValue = scale
		animation.duration = duration
		self.addAnimation(animation, forKey: "node scale")
		self.scale = scale

		DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + duration) {
			completion?()
		}
	}

	public func hasChildNode(_ node: SCNNode) -> Bool {
		var isChild = false
		self.enumerateChildNodes({ (child, stop) in
			if child == node {
				isChild = true
				stop.pointee = true
			}
		})
		return isChild
	}

	public func showPivot(_ color: NSColor = .red) {
		let primarySize = max(0.1, ((boundingBox.max.x - boundingBox.min.x) + (boundingBox.max.y - boundingBox.min.y)) / 2)
		let dotSize = CGFloat(primarySize / 20)
		let materialColor = SCNMaterial()
		materialColor.diffuse.contents = color
		let dot = SCNSphere(radius: dotSize)
		dot.materials = [materialColor]
		let dotNode = SCNNode(geometry: dot)
		dotNode.position.x = self.pivot.m41
		dotNode.position.y = self.pivot.m42
		dotNode.position.z = 0
		dotNode.scale = scale
		addChildNode(dotNode)
	}

	public func pivotAtCorner(_ corner: RectCorner, showPivotWithColor pivotColor: NSColor? = nil) {

		if let geometry = geometry as? SCNText, let text = geometry.string as? String {

			let textString = NSAttributedString(string: text, attributes: [NSAttributedStringKey.font: geometry.font])
			let containerSize = geometry.containerFrame.size

			let container = NSTextContainer(size: containerSize)
			container.lineFragmentPadding = 0.0

			let layoutManager = NSLayoutManager()
			layoutManager.addTextContainer(container)

			let storage = NSTextStorage(attributedString: textString)
			storage.addLayoutManager(layoutManager)

			layoutManager.glyphRange(forBoundingRect: CGRect(origin: .zero, size: containerSize), in: container)

			var textSize = layoutManager.usedRect(for: container).size
			textSize.height = max(textSize.height, geometry.font.pointSize - geometry.font.descender)	// adjustment for single-line text

			print("\(text): \(textSize), size: \(textString.size())")

			geometry.containerFrame.size = textSize

			switch corner {
			case .allCorners:
				pivot = SCNMatrix4MakeTranslation(CGFloat(textSize.width / 2), CGFloat(textSize.height / 2), 0)
			case .topLeft:
				pivot = SCNMatrix4MakeTranslation(0, CGFloat(textSize.height), 0)
			case .topRight:
				pivot = SCNMatrix4MakeTranslation(CGFloat(textSize.width), CGFloat(textSize.height), 0)
			case .bottomLeft:
				pivot = SCNMatrix4MakeTranslation(0, 0, 0)
			case .bottomRight:
				pivot = SCNMatrix4MakeTranslation(CGFloat(textSize.width), 0, 0)
			default:
				pivot = SCNMatrix4Identity
			}
		}

		if let geometry = geometry as? SCNBox {

			switch corner {
			case .allCorners:
				pivot = SCNMatrix4Identity
			case .topLeft:
				pivot = SCNMatrix4MakeTranslation(CGFloat(-geometry.width) / 2, CGFloat(geometry.height) / 2, 0)
			case .topRight:
				pivot = SCNMatrix4MakeTranslation(CGFloat(geometry.width) / 2, CGFloat(geometry.height) / 2, 0)
			case .bottomLeft:
				pivot = SCNMatrix4MakeTranslation(CGFloat(-geometry.width) / 2, CGFloat(-geometry.height) / 2, 0)
			case .bottomRight:
				pivot = SCNMatrix4MakeTranslation(CGFloat(geometry.width) / 2, CGFloat(-geometry.height) / 2, 0)
			default:
				pivot = SCNMatrix4Identity
			}
		}

		if let color = pivotColor {
			showPivot(color)
		}

	}

	private func heightForString(_ string: NSAttributedString, withWidth width: CGFloat) -> CGFloat {

		let size = CGSize(width:width, height:CGFloat.greatestFiniteMagnitude)
		let container = NSTextContainer(size: size)
		container.lineFragmentPadding = 0.0

		let layoutManager = NSLayoutManager()
		layoutManager.addTextContainer(container)

		NSTextStorage(attributedString: string).addLayoutManager(layoutManager)

		layoutManager.glyphRange(forBoundingRect: CGRect(origin: .zero, size: size), in: container)

		return layoutManager.usedRect(for: container).size.height
	}


	/// only supports aligning to placeholder nodes with SCNBox geometries
	public func alignToPlaceholder(_ placeholderNode: SCNNode, atCorner corner: RectCorner, showPivotWithColor pivotColor: NSColor? = nil) {

		guard let placeholderBox = placeholderNode.geometry as? SCNBox else {
			fatalError("alignToPlaceholder: placeholder node does not have SCNBox geometry")
		}

		guard parent == placeholderNode.parent else {
			fatalError("alignToPlaceholder: node and placeholder nodes are not siblings")
		}

		self.pivotAtCorner(corner, showPivotWithColor: pivotColor)
		self.position = placeholderNode.position

		switch corner {
		case .topLeft:
			self.position.x -= CGFloat(placeholderBox.width / 2)
			self.position.y += CGFloat(placeholderBox.height / 2)
		case .topRight:
			self.position.x += CGFloat(placeholderBox.width / 2)
			self.position.y += CGFloat(placeholderBox.height / 2)
		case .bottomLeft:
			self.position.x -= CGFloat(placeholderBox.width / 2)
			self.position.y -= CGFloat(placeholderBox.height / 2)
		case .bottomRight:
			self.position.x += CGFloat(placeholderBox.width / 2)
			self.position.y -= CGFloat(placeholderBox.height / 2)
		default:
			break
		}

		self.position.z += placeholderBox.length
	}

	public func showAxes() {
		addLetter(letter: "o", to: self, at: SCNVector3(0, 0, 0))
		addLetter(letter: "X", to: self, at: SCNVector3(1, 0, 0))
		addLetter(letter: "Y", to: self, at: SCNVector3(0, 1, 0))
		addLetter(letter: "Z", to: self, at: SCNVector3(0, 0, 1))
	}

	func addLetter(letter: String, to: SCNNode, at: SCNVector3) {
		let blackMaterial = SCNMaterial()
		blackMaterial.diffuse.contents = NSColor.black

		let x = SCNText(string: letter, extrusionDepth: 1)
		x.materials = [blackMaterial]
		let xNode = SCNNode(geometry: x)
		xNode.scale = SCNVector3(0.01, 0.01, 0.01)
		xNode.position = at
		to.addChildNode(xNode)
	}


}

