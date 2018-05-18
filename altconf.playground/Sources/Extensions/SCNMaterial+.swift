import Foundation
import SceneKit

public extension SCNMaterial {

	static var black: 		SCNMaterial { return materialWithColor(.black) }
	static var blue: 		SCNMaterial { return materialWithColor(.blue) }
	static var clear: 		SCNMaterial { return materialWithColor(.clear) }
	static var darkGray:	SCNMaterial { return materialWithColor(.darkGray) }
	static var gray: 		SCNMaterial { return materialWithColor(.gray) }
	static var green: 		SCNMaterial { return materialWithColor(.green) }
	static var lightGray: 	SCNMaterial { return materialWithColor(.lightGray) }
	static var red: 		SCNMaterial { return materialWithColor(.red) }
	static var white: 		SCNMaterial { return materialWithColor(.white) }
	static var yellow: 		SCNMaterial { return materialWithColor(.yellow) }

	static var magic: SCNMaterial {
		let material = SCNMaterial()
		material.colorBufferWriteMask = []
		return material
	}

	static func materialWithColor(_ color: NSColor) -> SCNMaterial {
		let material = SCNMaterial()
		material.diffuse.contents = color
		return material
	}

}



