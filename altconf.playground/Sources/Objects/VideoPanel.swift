// Erwin Mazariegos
// Altconf 2018: AR+SceneKit Tips & Tricks

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

		addTitleText(title: title)
		addVideoFile(videoFile)
	}

	public required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}

	public func reset() {
		LogFunc()
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

//		let yPosition = ((panelGeometry.height + headerGeometry.height - 10) / 2) * topNode.scale.y
		let titleTextNode = SCNNode(geometry: nodeGeometry)
		titleTextNode.scale = headerNode.scale
		titleTextNode.position = SCNVector3(0, 0, 0)	// z = 0 means text is inside translucent node

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

		videoObserver = videoPlayer.addBoundaryTimeObserver(forTimes: [NSValue(time: CMTime(seconds: 0.5, preferredTimescale: 600))], queue: DispatchQueue.main) {
			if let observer = self.videoObserver {
				self.videoPlayer.removeTimeObserver(observer)
			}
			self.loopVideoSlice()
		}

		videoPlayer.volume = 0
		videoPlayer.play()
	}

	func loopVideoSlice() {
		LogFunc()

		guard let item = videoPlayer.currentItem else {
			return
		}
		let fullDuration = item.duration
		let sliceStart = CMTimeMultiplyByFloat64(fullDuration, 0.25)
		let sliceEnd = CMTimeAdd(sliceStart, CMTime(seconds: 4, preferredTimescale: fullDuration.timescale))

		// different behavior on different platforms ¯\_(ツ)_/¯
#if os(OSX)
		videoObserver = videoPlayer.addBoundaryTimeObserver(forTimes: [NSValue(time: sliceStart), NSValue(time: sliceEnd)], queue: DispatchQueue.main) {
			if CMTimeCompare(self.videoPlayer.currentTime(), sliceEnd) == 1 {
				self.videoPlayer.rate = -1
			}
			if CMTimeCompare(self.videoPlayer.currentTime(), sliceStart) == -1 {
				self.videoPlayer.rate = 1
			}
		}
#else
		videoObserver = videoPlayer.addBoundaryTimeObserver(forTimes: [NSValue(time: sliceEnd)], queue: DispatchQueue.main) {
			self.videoPlayer.rate = -1
		}
		// reseting videoObserver like this works much better than setting both boundaries in one call (which doesn't work at all)
		videoObserver = videoPlayer.addBoundaryTimeObserver(forTimes: [NSValue(time: sliceStart)], queue: DispatchQueue.main) {
			self.videoPlayer.rate = 1
		}
#endif

		videoPlayer.seek(to: sliceStart)
		videoPlayer.play()
	}

}


