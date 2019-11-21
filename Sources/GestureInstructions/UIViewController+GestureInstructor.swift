//
//  UIViewController+GestureInstructor.swift
//  GestureInstructions
//
//  Created by Rinat Enikeev on 11/19/19.
//  Copyright © 2019 Rinat Enikeev. All rights reserved.
//

import UIKit
import ObjectiveC

private var AssociatedObjectHandle: UInt8 = 0

public extension UIViewController {
    var gestureInstructor: GestureInstructor {
        get {
            if let gi = objc_getAssociatedObject(self, &AssociatedObjectHandle) as? GestureInstructor {
                return gi
            } else {
                let gi = GestureInstructor(viewController: self)
                self.gestureInstructor = gi
                return gi
            }
        }
        set {
            objc_setAssociatedObject(self, &AssociatedObjectHandle, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
