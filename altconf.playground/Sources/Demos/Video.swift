import Foundation
import SceneKit
import SpriteKit

extension Demos {

	public struct Video {

		public enum DemoMode {
			case temp
		}

		public static func runwithView(_ sceneView: ARView, mode: DemoMode) {
			LogFunc()

			sceneView.scene?.rootNode.addChildNode(SCNNode())

			//			switch mode {
			//			case .oneCentered:
			//
			//			case .oneTopLeft:
			//
			//			case .varyLengthsCentered:
			//
			//			case .varyLengthsBottomLeft:
			//
			//			case .sphericalTitle:
			//
			//			}
		}

	}

}


