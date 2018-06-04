//  altConf
//  Created by Erwin Mazariegos on 6/4/18 using Swift 4.0.
//  Copyright © 2018 Erwin. All rights reserved.

import Foundation
import SceneKit
import SpriteKit
import AVFoundation

public class VideoPanel: SCNNode {

	var panelIndex = 0

	var headerNode = SCNNode()
	var screenNode = SCNNode()

	var headerGeometry = SCNPlane()
	var screenGeometry = SCNBox()

	public var videoPlayer = AVPlayer()
	public var videoObserver: Any?

	public typealias NodeAction = (node: SCNNode, action: SCNAction)
	public var openActions = [NodeAction]()
	public var closeActions = [NodeAction]()
	public var isOpen = false

	override init() {
		super.init()
	}

	public init(title: String, videoFile: String, index: Int) {
		LogFunc()

		guard let scene = SCNScene(named: "VideoNode.scn"),
			let containerNode = scene.rootNode.childNode(withName: "container", recursively: true),
			let topNode = containerNode.childNode(withName: "panelTop", recursively: true),
			let screen = containerNode.childNode(withName: "screen", recursively: true),
			let topGeometry = topNode.geometry as? SCNPlane,
			let contentGeometry = screen.geometry as? SCNBox
			else {
				fatalError("could not load root panel node and subnodes")
		}

		panelIndex = index
		headerNode = topNode
		screenNode = screen
		headerGeometry = topGeometry
		screenGeometry = contentGeometry

		super.init()

		containerNode.childNodes.forEach({
			self.addChildNode($0)
		})

		processActionsInNode()
		addTitleText(title: title)
		addVideoFile(videoFile)
	}

	public required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}

	private var playerItemDurationToken: NSKeyValueObservation?

	public func playbackLooped() {
		LogFunc()

		guard let item = videoPlayer.currentItem else {
			return
		}

		let fullDuration = item.duration

		guard !CMTIME_IS_INDEFINITE(fullDuration) else {
			// item isn't fully loaded yet. Set uo key-value observing so we try again when it is.
			playerItemDurationToken = item.observe(\.duration) { [weak self] object, change in
				self?.playbackLooped()
			}
			return
		}

		let sliceStart = CMTimeMultiplyByFloat64(fullDuration, 0.25)
		let sliceEnd = CMTimeAdd(sliceStart, CMTime(seconds: 4, preferredTimescale: fullDuration.timescale))

		// on iOS, setting both boundaries in one call doesn't work
		videoObserver = videoPlayer.addBoundaryTimeObserver(forTimes: [NSValue(time: sliceEnd)], queue: DispatchQueue.main) {
			self.videoPlayer.rate = -1
		}
		// even though we're overwriting the videoObserver token, this actually works
		videoObserver = videoPlayer.addBoundaryTimeObserver(forTimes: [NSValue(time: sliceStart)], queue: DispatchQueue.main) {
			self.videoPlayer.rate = 1
		}

		videoPlayer.seek(to: sliceStart)
		videoPlayer.play()
	}

	public func playbackNormal() {
		LogFunc()
		if let observer = videoObserver {
			videoPlayer.removeTimeObserver(observer)
			videoObserver = nil
		}
		let beginning = CMTime(seconds: 0, preferredTimescale: 600)
		videoPlayer.seek(to: beginning)
		videoPlayer.play()
	}

	/// extract actions defined in Scene editor for use as needed
	func processActionsInNode() {
		LogFunc()

		childNodes.forEach({ node in
			if node.hasActions  {
				let key = node.actionKeys[0]
				if let open = node.action(forKey: key) {
					let closed = open.reversed()
					openActions.append(NodeAction(node, open))
					closeActions.append(NodeAction(node, closed))
				}
				// now that we have refernces to the actions,
				// we remove them from the node so they don't run on their own
				node.removeAllActions()
			}
		})
	}

	func addTitleText(title: String) {
		LogFunc()
		let contentSize = CGSize(width: headerGeometry.width, height: headerGeometry.height)
		let scale: CGFloat = 10		// for shaprer text rendering
		let sceneSize = contentSize.applying(CGAffineTransform(scaleX: scale, y: scale))
		let sceneFrame = CGRect(origin: .zero, size: sceneSize).integral

		let skScene = SKScene(size: sceneFrame.size)
		skScene.backgroundColor = .clear

		let label = SKLabelNode(text: title)
		label.yScale = -1
		label.fontColor = .yellow
		label.fontName = "Helvetica"
		label.fontSize = 32
		label.horizontalAlignmentMode = .center
		label.verticalAlignmentMode = .center
		label.numberOfLines = 0
		label.preferredMaxLayoutWidth = contentSize.width * scale
		label.position = CGPoint(x: floor(sceneSize.width / 2), y: floor(sceneSize.height / 2))
		skScene.addChild(label)

		let textMaterial = SCNMaterial()
		textMaterial.isDoubleSided = true
		textMaterial.lightingModel = .constant
		textMaterial.diffuse.contents = skScene
		textMaterial.reflective.contents = UIColor.black

		let nodeGeometry = SCNPlane(width: sceneSize.width, height: sceneSize.height)
		nodeGeometry.materials = [textMaterial]

		let titleTextNode = SCNNode(geometry: nodeGeometry)
		titleTextNode.position = SCNVector3(0, headerGeometry.height / 2 - label.fontSize, 0.1)

		headerNode.addChildNode(titleTextNode)
	}

	func addVideoFile(_ fileName: String) {
		LogFunc()

		let videoURL = URL(fileReferenceLiteralResourceName: fileName)

		let skScene = SKScene(size: CGSize(width: screenGeometry.width, height: screenGeometry.height))

		videoPlayer = AVPlayer(url: videoURL)
		let videoNode = SKVideoNode(avPlayer: videoPlayer)
		videoNode.position = CGPoint(x: skScene.size.width/2, y: skScene.size.height/2)
		videoNode.size = skScene.size
		skScene.addChild(videoNode)

		// flip video upside down so it renders properly
		// FIXME: video is still flipped left-right
		var transform = SCNMatrix4MakeRotation(.pi, 0.0, 0.0, 1.0)
		transform = SCNMatrix4Translate(transform, 1.0, 1.0, 0.0)

		let videoMaterial = SCNMaterial()
		videoMaterial.diffuse.contents = skScene
		videoMaterial.diffuse.contentsTransform = transform
		videoMaterial.lightingModel = .constant	// so we don't have to point a light at it to see it
		screenGeometry.materials = [videoMaterial]

		playbackLooped()
	}

}
