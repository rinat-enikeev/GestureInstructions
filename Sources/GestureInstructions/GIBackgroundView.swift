//
//  GIBackgroundView.swift
//  GestureInstructions
//
//  Created by Rinat Enikeev on 11/19/19.
//  Copyright © 2019 Rinat Enikeev. All rights reserved.
//

import UIKit

protocol GIDelegate: class {
    func userDidTouch(view: UIView?, event: UIEvent?)
    func allowContentTouches() -> Bool
}

class GIBackgroundView: UIView {
    weak var delegate: GIDelegate?
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: superview)
        removeConstraints(constraints)
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        guard let superview = superview else { return }
        translatesAutoresizingMaskIntoConstraints = false
        let h = NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|", options: .alignAllTop, metrics: nil, views: ["view": self])
        let v = NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|", options: .alignAllTop, metrics: nil, views: ["view": self])
        superview.addConstraints(h)
        superview.addConstraints(v)
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let inside = super.point(inside: point, with: event)
        if inside {
            DispatchQueue.main.async { [weak self] in
                self?.delegate?.userDidTouch(view: self, event: event)
            }
        }
        if let allow = delegate?.allowContentTouches(), allow {
            return false
        }
        return inside
    }
}
