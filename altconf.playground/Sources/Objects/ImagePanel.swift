import Foundation
import SceneKit

class ImageNode: SCNNode {

	var panelIndex = 0
	var panelTitle = ""
	var headerNode = SCNNode()
	var panelNode = SCNNode()
	var imageNode = SCNNode()

	var originalPanelGeometry = SCNBox()
	var originalImageGeometry = SCNPlane()

	init(title: String, index: Int, fromSceneNamed sceneName: String) {

		var fullName = sceneName
		if !sceneName.hasSuffix(".scn") {
			fullName = sceneName.appending(".scn")
		}

		guard let scene = SCNScene(named: fullName),
			let containerNode = scene.rootNode.childNode(withName: "container", recursively: true),
			let topNode = containerNode.childNode(withName: "header", recursively: true),
			let backingNode = containerNode.childNode(withName: "panel", recursively: true),
			let contentNode = containerNode.childNode(withName: "content", recursively: true),
			let panelGeometry = panelNode.geometry as? SCNBox,
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

		super.init()

		containerNode.childNodes.forEach({
			self.addChildNode($0)
		})
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}

	func restoreGeometry() {
		panelNode.geometry = originalPanelGeometry
		imageNode.geometry = originalImageGeometry
	}

}

