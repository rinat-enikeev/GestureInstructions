//
//  ViewController.swift
//  GestureInstructions
//
//  Created by rinat-enikeev on 11/19/2019.
//  Copyright (c) 2019 rinat-enikeev. All rights reserved.
//

import UIKit
import GestureInstructions

class ViewController: UIViewController {

    @IBOutlet weak var showButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GestureInstructor.appearance.tapImage = UIImage(named: "hand")
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        gestureInstructor.dismissThenResume()
    }

    @IBAction func showButtonTouchUpInside(_ sender: Any) {
        let controller = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        controller.addAction(UIAlertAction(title: "Tap", style: .default, handler: { [weak self] _ in
            self?.gestureInstructor.show(.tap, targetView: self?.showButton, after: 0.1)
        }))
        controller.addAction(UIAlertAction(title: "DoubleTap", style: .default, handler: { [weak self] _ in
            self?.gestureInstructor.show(.doubleTap, targetView: self?.showButton, after: 0.1)
        }))
        controller.addAction(UIAlertAction(title: "LongPress", style: .default, handler: { [weak self] _ in
            self?.gestureInstructor.show(.longPress, targetView: self?.showButton, after: 0.1)
        }))
        controller.addAction(UIAlertAction(title: "SwipeUp", style: .default, handler: { [weak self] _ in
            self?.gestureInstructor.show(.swipeUp, after: 0.1)
        }))
        controller.addAction(UIAlertAction(title: "SwipeDown", style: .default, handler: { [weak self] _ in
            self?.gestureInstructor.show(.swipeDown, after: 0.1)
        }))
        controller.addAction(UIAlertAction(title: "SwipeLeft", style: .default, handler: { [weak self] _ in
            self?.gestureInstructor.show(.swipeLeft, after: 0.1)
        }))
        controller.addAction(UIAlertAction(title: "SwipeRight", style: .default, handler: { [weak self] _ in
            self?.gestureInstructor.show(.swipeRight, after: 0.1)
        }))
        present(controller, animated: true)
    }
    
}

