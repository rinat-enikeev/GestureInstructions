//
//  GIView.swift
//  GestureInstructions
//
//  Created by Rinat Enikeev on 11/19/19.
//  Copyright © 2019 Rinat Enikeev. All rights reserved.
//

import UIKit

class GIView: UIImageView {
    public private(set) var isPulsing: Bool = false
    
    static let size = CGSize(width: 44, height: 44)
    static let duration = TimeInterval(0.4)
    
    override var image: UIImage? {
        didSet {
            if image == nil {
                layer.masksToBounds = true
                layer.cornerRadius = bounds.size.height / 2.0
                layer.anchorPoint = anchorPointCenter
            } else {
                layer.masksToBounds = false
                layer.cornerRadius = 0
                layer.anchorPoint = anchorPointTopCenter
                backgroundColor = .clear
            }
        }
    }
    
    private let anchorPointCenter = CGPoint(x: 0.5, y: 0.5)
    private let anchorPointTopCenter = CGPoint(x: 0.5, y: 0.0)
    
    public func pulse(_ value: Bool) {
        if image == nil { return }
        if value {
            let a = CABasicAnimation(keyPath: "transform.scale")
            a.duration = GIView.duration
            a.repeatCount = .greatestFiniteMagnitude
            a.autoreverses = true
            a.fromValue = 1
            a.toValue = 1.17
            layer.add(a, forKey: "transform.scale")
        } else {
            layer.removeAllAnimations()
            UIView.animate(withDuration: 0.1) {
                self.transform = .identity
            }
        }
    }
    
    override init(frame: CGRect) {
        let f = CGRect(x: 0, y: 0, width: GIView.size.width, height: GIView.size.height)
        super.init(frame: f)
        layer.anchorPoint = anchorPointCenter
        isUserInteractionEnabled = false
        transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        alpha = 0.0
        image = nil
        contentMode = .scaleAspectFit
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: superview)
        layer.removeAllAnimations()
        transform = .identity
        alpha = 0.0
    }

}
