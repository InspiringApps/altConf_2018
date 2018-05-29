// Erwin Mazariegos
// Altconf 2018: AR+SceneKit Tips & Tricks

import Foundation
import SceneKit
import SpriteKit

public class ImagePanel: SCNNode {

	var panelIndex = 0
	var panelTitle = ""
	var headerNode = SCNNode()
	var panelNode = SCNNode()
	public var imageNode = SCNNode()

	public var originalPanelGeometry = SCNBox()
	public var originalImageGeometry = SCNPlane()
	public var originalImageNodeScale = SCNVector3()
	public var originalImageNodePosition = SCNVector3()

	public var contentImage: Image?

	override init() {
		super.init()
	}

	public init(title: String, image: Image?, index: Int) {
		LogFunc()

		guard let scene = SCNScene(named: "ImagePanel.scn"),
			let containerNode = scene.rootNode.childNode(withName: "container", recursively: true),
			let topNode = containerNode.childNode(withName: "header", recursively: true),
			let backingNode = containerNode.childNode(withName: "panel", recursively: true),
			let contentNode = containerNode.childNode(withName: "content", recursively: true),
			let headerGeometry = topNode.geometry as? SCNBox,
			let imageGeometry = contentNode.geometry as? SCNPlane,
			let panelGeometry = backingNode.geometry as? SCNBox
			else {
				fatalError("could not load root panel node and subnodes")
		}

		panelIndex = index
		panelTitle = title

		headerNode = topNode
		panelNode = backingNode
		imageNode = contentNode

		originalPanelGeometry = panelGeometry
		originalImageGeometry = imageGeometry
		originalImageNodeScale = imageNode.scale
		originalImageNodePosition = imageNode.position

		contentImage = image

		super.init()

		containerNode.childNodes.forEach({
			self.addChildNode($0)
		})

		let imageMaterial = SCNMaterial()
		imageMaterial.diffuse.contents = image
		imageNode.geometry?.materials = [imageMaterial]

		let contentSize = CGSize(width: headerGeometry.width, height: headerGeometry.height)
		let scale: CGFloat = 10		// for shaprer text rendering
		let sceneSize = contentSize.applying(CGAffineTransform(scaleX: scale, y: scale))
		let sceneFrame = CGRect(origin: .zero, size: sceneSize).integral

		let skScene = SKScene(size: sceneFrame.size)
		skScene.backgroundColor = .clear

		let label = SKLabelNode(text: title)
		label.yScale = -1
		label.fontColor = .magenta
		label.fontName = "Helvetica"
		label.fontSize = 24
		label.horizontalAlignmentMode = .center
		label.verticalAlignmentMode = .center
		label.numberOfLines = 0
		label.preferredMaxLayoutWidth = contentSize.width * scale
		label.position = CGPoint(x: floor(sceneSize.width / 2), y: floor(sceneSize.height / 2))
		skScene.addChild(label)

		let textMaterial = SCNMaterial()
		textMaterial.isDoubleSided = true
		textMaterial.diffuse.contents = skScene

		let nodeGeometry = SCNPlane(width: sceneSize.width, height: sceneSize.height)
		nodeGeometry.materials = [textMaterial]

		let yPosition = ((panelGeometry.height + headerGeometry.height - 10) / 2) * topNode.scale.y
		let titleTextNode = SCNNode(geometry: nodeGeometry)
		titleTextNode.scale = topNode.scale
		titleTextNode.position = SCNVector3(0, yPosition, 0)	// z = 0 means text is inside translucent node

		self.addChildNode(titleTextNode)
	}

	public required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}

	public func reset() {
		LogFunc()
		addChildNode(imageNode)
		panelNode.geometry = originalPanelGeometry
		imageNode.geometry = originalImageGeometry
		imageNode.scale = originalImageNodeScale
		imageNode.position = originalImageNodePosition
		imageNode.eulerAngles.y = 0
	}

}

