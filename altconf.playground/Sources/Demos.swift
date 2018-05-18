import Foundation
import SceneKit
import SpriteKit

public struct Demos {

	public struct Measurement {

		public enum DemoMode {
			case single, random, all
		}

		public static func runwithView(_ sceneView: ARView, mode: DemoMode) {

			let radius: CGFloat = 0.05

			let start = SCNNode(geometry: SCNSphere(radius: radius))
			start.geometry?.materials = [SCNMaterial.black]
			start.position = SCNVector3(x: 0.5, y: 0.2, z: -1)
			sceneView.scene?.rootNode.addChildNode(start)

			func addRulerTo(_ endPoint: SCNVector3) {

				let end = SCNNode(geometry: SCNSphere(radius: radius))
				end.geometry?.materials = [SCNMaterial.white]
				end.position = endPoint
				sceneView.scene?.rootNode.addChildNode(end)

				let line = Ruler(startPosition: start.position, material: SCNMaterial.blue, radius: radius / 2)
				sceneView.scene?.rootNode.addChildNode(line)
				line.measureTo(end.position)

				let pane = PictureNode(at: start.position)
				sceneView.scene?.rootNode.addChildNode(pane)
				pane.followRuler(line)
				//	pane.showPivot()
				pane.showAxes()
			}

			let points = [
				SCNVector3(4, 0, 0),
				SCNVector3(-2, 2, -3),
				SCNVector3(2, 2, -3),
				SCNVector3(-2, 2, 3),
				SCNVector3(2, -2, 1),
				SCNVector3(2, 2, 1),
				SCNVector3(-2, -2, 1)
			]

			switch mode {
			case .single:
				addRulerTo(points[0])
			case .random:
				let point = points[Int(arc4random_uniform(UInt32(points.count - 1)))]
				addRulerTo(point)
			case .all:
				points.forEach({ addRulerTo($0) })
			}
		}
	}

	public struct Text {

		public enum DemoMode {
			case oneCentered, oneTopLeft, varyLengthsCentered, varyLengthsBottomLeft
		}

		public static func runwithView(_ sceneView: ARView, mode: DemoMode) {

			let text = "AltConf is a community-driven event, assembled to serve developers and a product driven community. Held in downtown San Jose at the San Jose Marriott with 900 seats spread over 2 theatres. AltConf is an annual event timed alongside Apple‘s WWDC, June 4-7, 2018."

			let panelScale: CGFloat = 0.2
			let nodeScale = SCNVector3(panelScale, panelScale, panelScale)

			func addNodeForText(_ text: String, withPivotCorner corner: RectCorner, index: Int) {

				let panelGeometry = SCNBox(width: 20, height: 30, length: 1, chamferRadius: 3)
				panelGeometry.materials = [SCNMaterial.black]

				let headerHeight: CGFloat = 5

				let placeholderGeometry = SCNBox(width: 20, height: panelGeometry.height - headerHeight, length: 1, chamferRadius: 3)
				placeholderGeometry.materials = [SCNMaterial.clear]

				let panelNode = SCNNode(geometry: panelGeometry)
				panelNode.position = SCNVector3(0, CGFloat(index - 1) * (panelGeometry.height + 35) * 0.1, 0)
				panelNode.scale = SCNVector3(0.2, 0.2, 0.2)

				let placeholderNode = SCNNode(geometry: placeholderGeometry)
				placeholderNode.position = SCNVector3(0, -headerHeight / 2, 0.05)
				panelNode.addChildNode(placeholderNode)

				let titleTextNode = labelNodeForText("AltConf 2018", withSize: CGSize(width: panelGeometry.width, height: headerHeight), atScale: panelScale)
				titleTextNode.position = SCNVector3(0, (panelGeometry.height - headerHeight) / 2, panelGeometry.length / 2 + 0.01)
				panelNode.addChildNode(titleTextNode)

				let tagText = SCNText(string: text, extrusionDepth: 0.2)
				tagText.isWrapped = true
				tagText.containerFrame = CGRect(origin: .zero, size: CGSize(width: placeholderGeometry.width, height: placeholderGeometry.height))
				tagText.font = .systemFont(ofSize: 2)
				tagText.materials = [SCNMaterial.white]

				let tagTextNode = SCNNode(geometry: tagText)
				tagTextNode.position = SCNVector3(0, 0, 1)
				panelNode.addChildNode(tagTextNode)

				tagTextNode.alignToPlaceholder(placeholderNode, atCorner: corner, showPivotWithColor: .red)

				sceneView.scene?.rootNode.addChildNode(panelNode)

				//	sceneView.makeRotatable(panelNode)
			}

			switch mode {
			case .oneCentered:
				addNodeForText(String(text.prefix(150)), withPivotCorner: .allCorners, index: 1)
			case .oneTopLeft:
				addNodeForText(String(text.prefix(100)), withPivotCorner: .topLeft, index: 1)
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
			}
		}

		static func labelNodeForText(_ text: String, withSize contentSize: CGSize, atScale scale: CGFloat) -> SCNNode {

			let skScene = SKScene(size: CGSize(width: contentSize.width / scale, height: contentSize.height / scale))
			skScene.backgroundColor = NSColor.black

			let label = SKLabelNode(text: text)
			label.yScale = -1
			label.fontColor = .green
			label.fontName = "Helvetica"
			label.fontSize = 12
			label.horizontalAlignmentMode = .center
			label.verticalAlignmentMode = .center
			label.numberOfLines = 0
			label.preferredMaxLayoutWidth = contentSize.width * 20
			label.position = CGPoint(x: (contentSize.width / 2) / scale , y: (contentSize.height / 2) / scale)
			skScene.addChild(label)

			let textMaterial = SCNMaterial()
			textMaterial.diffuse.contents = skScene

			let nodeGeometry = SCNPlane(width: contentSize.width, height: contentSize.height)
			nodeGeometry.cornerRadius = 3 * scale
			nodeGeometry.materials = [textMaterial]
			return SCNNode(geometry: nodeGeometry)
		}

	}

}
