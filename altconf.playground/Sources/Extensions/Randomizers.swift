import Foundation

extension Array {
	func randomItem() -> Element? {
		guard !self.isEmpty else {
			return nil
		}
		return self[ Int(arc4random_uniform(UInt32(self.count))) ]
	}
}

extension Collection {
	func randomItem() -> Element? {
		return Array(self).randomItem()
	}
}

extension Bool {
	static func randomSign() -> Int {
		return arc4random_uniform(UInt32(100)) % 2 == 1 ? 1 : -1
	}
	static func random() -> Bool {
		return randomSign() == 1
	}
}
