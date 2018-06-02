//  altConf
//  Created by Erwin Mazariegos on 6/2/18.
//  Copyright (c) 2018 Erwin. All rights reserved.

import UIKit

class DemoViewController: UIViewController {

	@IBOutlet weak var splashImage: UIImageView!

	enum DemoViews {
		case measure, panels, portal
	}

	override func viewDidLoad() {
		LogFunc()
        super.viewDidLoad()
    }

	override func viewDidAppear(_ animated: Bool) {
		LogFunc()
		super.viewDidAppear(animated)

		fadeAway()

		showDemo(.portal)
	}

    override func didReceiveMemoryWarning() {
		LogFunc()
        super.didReceiveMemoryWarning()
    }

	func fadeAway() {
		LogFunc()
		UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
			self.splashImage.alpha = 0
			self.splashImage.transform = CGAffineTransform(scaleX: 0.2, y: 0.2).rotated(by: 90 * .pi / 180)
			self.view.backgroundColor = .black
		}) { (completed) in
		}
	}

	func showDemo(_ demo: DemoViews) {
		LogFunc()

		guard let storyboard = self.storyboard  else {
			fatalError("No storyboard! weird...")
		}

		switch demo {
		case .measure:
			break
		case .panels:
			break
		case .portal:
			let controller = storyboard.instantiateViewController(withIdentifier: "\(PortalViewController.self)")
			present(controller, animated: true, completion: nil)
		}
	}



}
