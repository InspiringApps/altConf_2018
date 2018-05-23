import Foundation
import SceneKit

public class ImageNode: SCNNode {

	var panelIndex = 0
	var panelTitle = ""
	var headerNode = SCNNode()
	var panelNode = SCNNode()
	var imageNode = SCNNode()

	var originalPanelGeometry = SCNBox()
	var originalImageGeometry = SCNPlane()

	var contentImage: Image?

	public init(title: String, image: Image?, index: Int) {

		guard let scene = SCNScene(named: "ImagePanel.scn"),
			let containerNode = scene.rootNode.childNode(withName: "container", recursively: true),
			let topNode = containerNode.childNode(withName: "header", recursively: true),
			let backingNode = containerNode.childNode(withName: "panel", recursively: true),
			let contentNode = containerNode.childNode(withName: "content", recursively: true),
			let panelGeometry = backingNode.geometry as? SCNBox,
			let imageGeometry = contentNode.geometry as? SCNPlane
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

		contentImage = image

		super.init()

		containerNode.childNodes.forEach({
			self.addChildNode($0)
		})

		let imageMaterial = SCNMaterial()
		imageMaterial.diffuse.contents = image
		imageGeometry.materials = [imageMaterial]
	}

	public required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}

	public func restoreGeometry() {
		panelNode.geometry = originalPanelGeometry
		imageNode.geometry = originalImageGeometry
	}

}

