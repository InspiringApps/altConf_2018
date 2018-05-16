import Foundation
import SceneKit

#if os(OSX)
	public enum NSRectCorner { case allCorners, topLeft, topRight, bottomLeft, bottomRight, other	}
	public typealias RectCorner = NSRectCorner
#else
	public typealias RectCorner = UIRectCorner
#endif

extension SCNNode {

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
			let textSize = textString.boundingRect(with: geometry.containerFrame.size, options: .usesLineFragmentOrigin, context: nil).size

			switch corner {
			case .allCorners:
				pivot = SCNMatrix4MakeTranslation(CGFloat(geometry.containerFrame.width - textSize.width / 2), CGFloat(geometry.containerFrame.height - textSize.height / 2), 0)
			case .topLeft:
				pivot = SCNMatrix4MakeTranslation(0, CGFloat(geometry.containerFrame.height), 0)
			case .topRight:
				pivot = SCNMatrix4MakeTranslation(CGFloat(geometry.containerFrame.width), CGFloat(geometry.containerFrame.height), 0)
			case .bottomLeft:
				pivot = SCNMatrix4MakeTranslation(0, CGFloat(geometry.containerFrame.height - textSize.height), 0)
			case .bottomRight:
				pivot = SCNMatrix4MakeTranslation(CGFloat(geometry.containerFrame.width), CGFloat(geometry.containerFrame.height - textSize.height), 0)
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

