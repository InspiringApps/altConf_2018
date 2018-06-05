//  altConf
//  Created by Erwin Mazariegos on 6/2/18.
//  Copyright (c) 2018 Erwin. All rights reserved.

import UIKit

class DemoViewController: UIViewController {

	@IBOutlet weak var splashImage: UIImageView!
	@IBOutlet weak var infoView: UIView!

	override func viewDidLoad() {
		LogFunc()
        super.viewDidLoad()
		reset()
    }

	override func viewDidAppear(_ animated: Bool) {
		LogFunc()
		super.viewDidAppear(animated)
		fadeAway()
	}

	override func viewDidDisappear(_ animated: Bool) {
		LogFunc()
		super.viewDidDisappear(animated)
		reset()
	}

    override func didReceiveMemoryWarning() {
		LogFunc()
        super.didReceiveMemoryWarning()
    }

	func reset() {
		LogFunc()
		self.splashImage.alpha = 1
		self.splashImage.transform = CGAffineTransform.identity
		self.view.backgroundColor = .darkGray
		self.infoView.alpha = 0
		self.infoView.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
	}

	func fadeAway() {
		LogFunc()
		UIView.animate(withDuration: 0.75, delay: 0, options: .curveEaseIn, animations: {
			self.splashImage.alpha = 0
			self.splashImage.transform = CGAffineTransform(scaleX: 0.2, y: 0.2).rotated(by: 90 * .pi / 180)
			self.view.backgroundColor = .black
		}) { (completed) in
			self.fadeIn()
		}
	}

	func fadeIn() {
		LogFunc()
		UIView.animate(withDuration: 0.75, delay: 0, options: .curveEaseIn, animations: {
			self.infoView.alpha = 1
			self.infoView.transform = CGAffineTransform.identity
		}) { (completed) in
		}
	}
}
