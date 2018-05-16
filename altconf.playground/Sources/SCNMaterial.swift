import Foundation
import SceneKit

public extension SCNMaterial {

	static var blue: SCNMaterial {
		return materialWithColor(NSColor.blue)
	}

	static var green: SCNMaterial {
		return materialWithColor(NSColor.green)
	}

	static var gray: SCNMaterial {
		return materialWithColor(NSColor.gray)
	}

	static var white: SCNMaterial {
		return materialWithColor(NSColor.white)
	}

	static var red: SCNMaterial {
		return materialWithColor(NSColor.red)
	}

	static var black: SCNMaterial {
		return materialWithColor(NSColor.black)
	}

	static func materialWithColor(_ color: NSColor) -> SCNMaterial {
		let material = SCNMaterial()
		material.diffuse.contents = color
		return material
	}

}



