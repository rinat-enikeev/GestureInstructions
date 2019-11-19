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
    
    public func pulse(_ value: Bool) {
        
    }
}
