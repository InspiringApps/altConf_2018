//  altConf
//  Created by Erwin Mazariegos on 6/2/18.
//  Copyright (c) 2018 Erwin. All rights reserved.

import UIKit

class DemoViewController: UIViewController {

	@IBOutlet weak var splashImage: UIImageView!

	@IBAction func chooseDemo(_ sender: UISegmentedControl) {
		LogFunc()

		guard sender.selectedSegmentIndex > 0 else {
			return
		}

		if let demo = DemoViews(rawValue: sender.selectedSegmentIndex - 1) {
			showDemo(demo)
		}
	}
	
	enum DemoViews: Int {
		case measure, imagePanels, videoPanels, portal
	}

	override func viewDidLoad() {
		LogFunc()
        super.viewDidLoad()
    }

	override func viewDidAppear(_ animated: Bool) {
		LogFunc()
		super.viewDidAppear(animated)
		fadeAway()
	}

    override func didReceiveMemoryWarning() {
		LogFunc()
        super.didReceiveMemoryWarning()
    }

	func fadeAway() {
		LogFunc()
		UIView.animate(withDuration: 0.75, delay: 0, options: .curveEaseIn, animations: {
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

		let controllerClassName: String

		switch demo {
		case .measure:
			controllerClassName = "\(MeasuringViewController.self)"
		case .imagePanels:
			controllerClassName = "\(ImagePanelsViewController.self)"
		case .videoPanels:
			controllerClassName = "\(VideoBoxesViewController.self)"
		case .portal:
			controllerClassName = "\(PortalViewController.self)"
		}

		let controller = storyboard.instantiateViewController(withIdentifier: controllerClassName)
		present(controller, animated: true, completion: nil)
	}

}
