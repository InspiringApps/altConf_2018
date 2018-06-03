// Erwin Mazariegos
// Altconf 2018: AR+SceneKit Tips & Tricks

import Foundation
import SceneKit
import SpriteKit

extension Demos {

	public struct Text {

		public enum DemoMode {
			case oneBottomLeft, oneCentered, varyLengthsCentered, varyLengthsBottomLeft, sphericalTitle
			case addBlueMaterial, addSomeGray
		}

		public static func runwithView(_ sceneView: ARView, mode: DemoMode) {
			LogFunc()

			let text = "AltConf is a community-driven event, assembled to serve developers and a product driven community. Held in downtown San Jose at the San Jose Marriott with 900 seats spread over 2 theatres. AltConf is an annual event timed alongside Apple‘s WWDC, June 4-7, 2018."

			let headerHeight: CGFloat = 5
			var titleTextNode = SCNNode()
			var panelNode = SCNNode()

			// TODO: move this function outside of its parent function
			func addNodeForText(_ text: String, withPivotCorner corner: RectCorner, index: Int, materials: [SCNMaterial] = [SCNMaterial.white]) {

				let panelGeometry = SCNBox(width: 20, height: 30, length: 1, chamferRadius: 3)
				panelGeometry.materials = [SCNMaterial.black]

				let placeholderGeometry = SCNBox(width: 20, height: panelGeometry.height - headerHeight, length: 1, chamferRadius: 3)
				placeholderGeometry.materials = [SCNMaterial.clear]

				panelNode = SCNNode(geometry: panelGeometry)
				panelNode.position = SCNVector3(0, CGFloat(index - 1) * (panelGeometry.height + 35) * 0.1, 0)
				panelNode.scale = SCNVector3(0.2, 0.2, 0.2)

				let placeholderNode = SCNNode(geometry: placeholderGeometry)
				placeholderNode.position = SCNVector3(0, -headerHeight / 2, 0.05)
				panelNode.addChildNode(placeholderNode)

				titleTextNode = labelNodeForText("AltConf 2018", withSize: CGSize(width: panelGeometry.width, height: headerHeight))
				titleTextNode.position = SCNVector3(0, floor((panelGeometry.height - headerHeight) / 2), panelGeometry.length / 2 + 0.01)
				panelNode.addChildNode(titleTextNode)

				// for demo purposes, make the text thicker when we're showing multiple meaterials
				// to make the extruded surface easier to see
				let panelText = SCNText(string: text, extrusionDepth: 0.3 * CGFloat(materials.count))
				panelText.isWrapped = true
				panelText.containerFrame = CGRect(origin: .zero, size: CGSize(width: placeholderGeometry.width, height: placeholderGeometry.height))
				panelText.font = NSFont(name: "Helvetica", size: 2)
				panelText.materials = materials	// the order of the elements in the materials array matter. Refer to documentation for each geometry type

				let panelTextNode = SCNNode(geometry: panelText)
				panelTextNode.position = SCNVector3(0, 0, 1)
				panelNode.addChildNode(panelTextNode)

				// move text forward to make backside easier to see
				let hoverDistance = CGFloat(1 + ((materials.count - 1) * 2))

				panelTextNode.alignToPlaceholder(placeholderNode, atCorner: corner, hoverDistance: hoverDistance, showPivotWithColor: .red)

				sceneView.scene?.rootNode.addChildNode(panelNode)
			}

			switch mode {
			case .oneBottomLeft:
				addNodeForText(String(text.prefix(100)), withPivotCorner: .bottomLeft, index: 1)
				panelNode.showPivot()
			case .oneCentered:
				addNodeForText(String(text.prefix(150)), withPivotCorner: .allCorners, index: 1)
			case .varyLengthsCentered:
				let corner = RectCorner.allCorners
				addNodeForText(String(text.prefix(15)), withPivotCorner: corner, index: 0)
				addNodeForText(String(text.prefix(100)), withPivotCorner: corner, index: 1)
				addNodeForText(String(text.prefix(1500)), withPivotCorner: corner, index: 2)
			case .varyLengthsBottomLeft:
				let corner = RectCorner.bottomLeft
				addNodeForText(String(text.prefix(15)), withPivotCorner: corner, index: 0)
				addNodeForText(String(text.prefix(100)), withPivotCorner: corner, index: 1)
				addNodeForText(String(text.prefix(1500)), withPivotCorner: corner, index: 2)
			case .sphericalTitle:
				addNodeForText(String(text.prefix(150)), withPivotCorner: .allCorners, index: 1)

				if let titleGeometry = titleTextNode.geometry, let titleMaterial = titleGeometry.firstMaterial {
					let sphere = SCNSphere(radius: headerHeight)
					sphere.materials = [titleMaterial]
					titleTextNode.geometry = sphere
					sceneView.makeRotatable(titleTextNode)
				}
			case .addBlueMaterial:
				addNodeForText(String(text.prefix(150)), withPivotCorner: .allCorners, index: 1, materials: [SCNMaterial.white, SCNMaterial.blue])
			case .addSomeGray:
				addNodeForText(String(text.prefix(150)), withPivotCorner: .allCorners, index: 1, materials: [SCNMaterial.white, SCNMaterial.blue, SCNMaterial.gray])
			}
		}

		public static func labelNodeForText(_ text: String, withSize contentSize: CGSize) -> SCNNode {
			LogFunc()

			let scale: CGFloat = 10		// for shaprer text rendering
			let sceneSize = contentSize.applying(CGAffineTransform(scaleX: scale, y: scale))
			let sceneFrame = CGRect(origin: .zero, size: sceneSize).integral

			let skScene = SKScene(size: sceneFrame.size)
			skScene.backgroundColor = NSColor.black

			let label = SKLabelNode(text: text)
			label.yScale = -1
			label.fontColor = .green
			label.fontName = "Helvetica"
			label.fontSize = 24
			label.horizontalAlignmentMode = .center
			label.verticalAlignmentMode = .center
			label.numberOfLines = 0
			label.preferredMaxLayoutWidth = contentSize.width * scale
			label.position = CGPoint(x: floor(sceneSize.width / 2), y: floor(sceneSize.height / 2))
			skScene.addChild(label)

			let textMaterial = SCNMaterial()
			textMaterial.diffuse.contents = skScene

			let inset: CGFloat = 2	// make node slightly smaller so edges are not visible
			let nodeGeometry = SCNPlane(width: contentSize.width - inset, height: contentSize.height)
			nodeGeometry.cornerRadius = 3 * scale
			nodeGeometry.materials = [textMaterial]
			return SCNNode(geometry: nodeGeometry)
		}

	}

}
