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

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func swipeUpButtonTouchUpInside(_ sender: Any) {
        gestureInstructor.show(.swipeLeft, after: 0.1)
    }
    
}

