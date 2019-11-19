//
//  GIBackgroundView.swift
//  GestureInstructions
//
//  Created by Rinat Enikeev on 11/19/19.
//  Copyright © 2019 Rinat Enikeev. All rights reserved.
//

import UIKit

protocol GIDelegate: class {
    func userDidTouch(view: UIView, event: UIEvent)
    func allowContentTouches() -> Bool
}

class GIBackgroundView: UIView {
    weak var delegate: GIDelegate?
}
