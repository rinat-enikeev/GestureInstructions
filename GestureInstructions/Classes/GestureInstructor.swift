//
//  GestureAssistant.swift
//  GestureInstructions
//
//  Created by Rinat Enikeev on 11/18/19.
//  Copyright © 2019 Rinat Enikeev. All rights reserved.
//

import UIKit

public enum GISwipeDirection {
    case up
    case down
    case left
    case right
}

public enum GITap {
    case single
    case longPress
    case double
}

public enum GIOptions {
    case undefined
    case tap
    case doubleTap
    case longPress
    case swipeDown
    case swipeUp
    case swipeLeft
    case swipeRight
    case customSwipe
}

public class GIAppearance {
    public static let shared = GIAppearance()
    
    public var backgroundColor: UIColor = UIColor(white: 0.0, alpha: 0.7)
    public var textColor: UIColor = UIColor.darkGray
    public var tapColor: UIColor = UIColor.blue
    public var tapImage: UIImage?
}

public class GestureInstructor {
    
    public static var appearance: GIAppearance = GIAppearance.shared
    
    public private(set) var isAnimating: Bool = false
    public private(set) var mode: GIOptions = .undefined
    public var targetView: UIView?
    
    private var views = [GIView]()
    private var startPoistions = [CGPoint]()
    private var endPoistions = [CGPoint]()
    private var idleTimer: Timer?
    private weak var viewController: UIViewController?
    private lazy var backgroundView: GIBackgroundView = {
        let view = GIBackgroundView()
        view.delegate = self
        return view
    }()
    private lazy var descriptionLabel: UILabel? = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.alpha = 0
        return label
    }()
    private var lastEventDate: Date?
    private var window: UIWindow? {
        get {
            return viewController?.view.window
        }
    }
    private var idleTimerDelay: TimeInterval = 1
    private var completion: ((Bool) -> Void)?
    private var isFadingOut: Bool = false
    private var isFadingIn: Bool = false
    private var animationOptions: UIView.AnimationOptions = [UIView.AnimationOptions.curveEaseInOut, UIView.AnimationOptions.beginFromCurrentState, UIView.AnimationOptions.allowUserInteraction]
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    public func show(_ mode: GIOptions, targetView: UIView? = nil, startPoint: CGPoint? = nil, endPoint: CGPoint? = nil, attributedText: NSAttributedString? = nil, after delay: TimeInterval, completion: ((Bool) -> Void)? = nil) {
        guard mode != .undefined else { return }
        var start: CGPoint
        if startPoint == nil, let targetView = targetView {
            start = centerPoint(for: targetView)
        } else {
            start = startPoint ?? .zero
        }
        let end: CGPoint = endPoint ?? .zero
        
        dismiss { _ in
            switch mode {
            case .undefined:
                return
            case .tap:
                self.startPoistions = [start]
                self.endPoistions = []
            case .doubleTap:
                self.startPoistions = [start]
                self.endPoistions = []
            case .longPress:
                self.startPoistions = [start]
                self.endPoistions = []
            case .customSwipe:
                self.startPoistions = [start]
                self.endPoistions = [end]
            default:
                self.startPoistions = []
                self.endPoistions = []
            }
            
            self.mode = mode
            self.idleTimerDelay = max(0.1, delay)
            self.targetView = targetView
            self.completion = completion
            self.descriptionLabel?.attributedText = attributedText ?? NSAttributedString(string: "")
            self.startTimer()
        }
    }
}

// MARK: - GIDelegate
extension GestureInstructor: GIDelegate {
    func allowContentTouches() -> Bool {
        return completion == nil
    }
    
    func userDidTouch(view: UIView?, event: UIEvent?) {
        if let lastEventDate = lastEventDate, abs(lastEventDate.timeIntervalSinceNow) > 0.15 {
            self.lastEventDate = Date()
        } else if lastEventDate == nil {
            self.lastEventDate = Date()
        } else {
            return
        }
        
        if (isFadingOut || isFadingIn || backgroundView.backgroundColor == .clear) && completion != nil {
            return
        }
        
        if completion != nil {
            isFadingOut = true
            dismiss { _ in
                DispatchQueue.main.async {
                    self.completion?(true)
                    self.completion = nil
                }
                self.isFadingOut = false
            }
        } else {
            dismiss()
        }
    }
}

// MARK: - Private
private extension GestureInstructor {
    
    private func dismiss(completion: ((Bool) -> Void)? = nil) {
        isFadingOut = false
        isAnimating = true
        idleTimer?.invalidate()
        idleTimer = nil
        mode = .undefined
        window?.layer.removeAllAnimations()
        UIView.animate(withDuration: GIView.duration / 3.0, delay: 0, options: animationOptions, animations: {
            self.descriptionLabel?.alpha = 0
            self.backgroundView.backgroundColor = .clear
            self.views.forEach({ $0.alpha = 0.0 })
        }) { _ in
            // remove from window
            self.views.forEach({ $0.pulse(false); $0.layer.removeAllAnimations(); $0.removeFromSuperview() })
            self.viewController?.view.tintAdjustmentMode = .automatic
            self.viewController?.navigationController?.view.tintAdjustmentMode = .automatic
            
            self.isFadingOut = false
            
            self.backgroundView.removeFromSuperview()
            self.descriptionLabel?.removeFromSuperview()
            
            completion?(true)
        }
    }
    
    private func commitAnimation(delay: TimeInterval) {
        guard let viewController = viewController else { return }
        
        if viewController.presentedViewController != nil {
            startTimer()
            return
        } else if let top = viewController.navigationController?.topViewController,  viewController != top {
            dismiss()
        }
        
        
        idleTimer?.invalidate()
        idleTimer = nil
        
        for i in 0..<views.count {
            let view = views[i]
            let p0 = startPoistions[i]
            view.center = p0
            window?.addSubview(view)
        }
        
        isFadingIn = true
        isAnimating = false
        window?.layer.removeAllAnimations()
        isAnimating = true
        
        switch mode {
        case .undefined:
            return
        case .doubleTap:
            animateDoubleTap(with: delay)
        case .tap:
            animateTap(with: delay, timeScale: 0.7)
        case .longPress:
            animateTap(with: delay, timeScale: 4.4)
        default:
            animateSwipe(with: delay)
        }
        
        // fade in background
        UIView.animate(withDuration: GIView.duration, delay: delay, options: animationOptions, animations: {
            self.backgroundView.backgroundColor = GestureInstructor.appearance.backgroundColor
        }) { _ in
            self.isFadingIn = false
            viewController.view.tintAdjustmentMode = .dimmed
            viewController.navigationController?.view.tintAdjustmentMode = .dimmed
            UIView.animate(withDuration: GIView.duration) {
                self.descriptionLabel?.alpha = 1.0
            }
        }
    }
    
    private func animateSwipe(with delay: TimeInterval) {
        views.forEach({ $0.transform = CGAffineTransform(scaleX: 0.1, y: 0.1); $0.pulse(true) })
        
        // fade in gesture views
        UIView.animate(withDuration: GIView.duration * 2.0, delay: delay, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.6, options: animationOptions, animations: {
            self.views.forEach({ $0.alpha = 1.0; $0.transform = CGAffineTransform(scaleX: 1.0, y: 1.0) })
        }) { _ in
            // animate gesture views
            UIView.animate(withDuration: GIView.duration * 1.5, delay: GIView.duration * 3.0, options: self.animationOptions, animations: {
                for i in 0..<self.views.count {
                    let view = self.views[i]
                    let p1 = self.endPoistions[i]
                    view.center = p1
                    view.alpha = 0.5
                }
            }) { _ in
                // fade out gesture views
                UIView.animate(withDuration: GIView.duration * 2.0, delay: 0, options: self.animationOptions, animations: {
                    self.views.forEach({ $0.alpha = 0.0 })
                }) { _ in
                    if self.isAnimating && self.idleTimer == nil {
                        self.commitAnimation(delay: 0)
                    }
                }
            }
        }
    }
    
    private func animateTap(with delay: TimeInterval, timeScale: TimeInterval) {
        
        let tapDnDuration = GIView.duration * 0.67 * timeScale
        let tapUpDuration = GIView.duration
        
        // fade in gesture views
        UIView.animate(withDuration: GIView.duration * 2.0, delay: delay, options: animationOptions, animations: {
            self.views.forEach({ $0.alpha = 1.0; $0.transform = CGAffineTransform(scaleX: 1.2, y: 1.2) })
        }) { _ in
            // first tap
            
            UIView.animate(withDuration: tapDnDuration, delay: GIView.duration * 2, options: self.animationOptions, animations: {
                self.views.forEach({ $0.alpha = 0.75; $0.transform = CGAffineTransform(scaleX: 1.0, y: 1.0) })
            }) { _ in
                // animate up
                UIView.animate(withDuration: tapUpDuration, delay: 0, options: self.animationOptions, animations: {
                    self.views.forEach({ $0.alpha = 1.0; $0.transform = CGAffineTransform(scaleX: 1.2, y: 1.2) })
                }) { _ in
                    if self.isAnimating && self.idleTimer == nil {
                        self.commitAnimation(delay: 0)
                    }
                }
            }
        }
    }
    
    private func animateDoubleTap(with delay: TimeInterval) {
        let tapDnDuration = GIView.duration / 3.0
        let tapUpDuration = GIView.duration / 2.0
        
        
        UIView.animate(withDuration: GIView.duration * 2.0, delay: delay, options: animationOptions, animations: {
            self.views.forEach({ $0.alpha = 1.0; $0.transform = CGAffineTransform(scaleX: 1.2, y: 1.2) })
        }) { _ in
            // first tap
            UIView.animate(withDuration: tapDnDuration, delay: GIView.duration * 2.0, options: self.animationOptions, animations: {
                self.views.forEach({ $0.alpha = 0.75; $0.transform = CGAffineTransform(scaleX: 1.0, y: 1.0) })
            }) { _ in
                // animate up
                UIView.animate(withDuration: tapUpDuration, delay: 0, options: self.animationOptions, animations: {
                    self.views.forEach({ $0.alpha = 1.0; $0.transform = CGAffineTransform(scaleX: 1.2, y: 1.2) })
                }) { _ in
                    // second tap
                    UIView.animate(withDuration: tapDnDuration, delay: 0, options: self.animationOptions, animations: {
                        self.views.forEach({ $0.alpha = 0.75; $0.transform = CGAffineTransform(scaleX: 1.0, y: 1.0) })
                    }) { _ in
                        // animate up
                        UIView.animate(withDuration: tapUpDuration * 2.0, delay: 0, options: self.animationOptions, animations: {
                            self.views.forEach({ $0.alpha = 1.0; $0.transform = CGAffineTransform(scaleX: 1.2, y: 1.2) })
                        }) { _ in
                            if self.isAnimating && self.idleTimer == nil {
                                self.commitAnimation(delay: delay)
                            }
                        }
                    }
                }
            }
        }
    }
    
    @objc private func timerTick(_ timer: Timer) {
        prepareBackground()
        prepareViews()
        commitAnimation(delay: 1)
    }
    
    private func startTimer() {
        idleTimer?.invalidate()
        idleTimer = nil
        idleTimer = Timer.scheduledTimer(timeInterval: idleTimerDelay, target: self, selector: #selector(GestureInstructor.timerTick(_:)), userInfo: nil, repeats: false)
    }
    
    private func prepareBackground() {
        backgroundView.backgroundColor = .clear
        window?.addSubview(backgroundView)
    }
    
    private func prepareViews() {
        guard let viewController = viewController else { return }
        guard let window = window else { return }
        
        views.forEach({ $0.removeFromSuperview() })
        
        var start: [CGPoint]
        var stop: [CGPoint]
        var viewCount = 0
        let screenWidth = window.frame.size.width
        let screenHeight = window.frame.size.height
        var screenTopMargin: CGFloat
        if let nb = viewController.navigationController?.navigationBar {
            screenTopMargin = max(30, nb.frame.origin.y + nb.frame.size.height)
        } else {
            screenTopMargin = 30
        }
        let horizontalCenter = screenWidth / 2
        
        switch mode {
        case .undefined:
            return
        case .swipeDown:
            viewCount = 1
            start = [CGPoint(x: horizontalCenter, y: round(screenHeight * 0.2))]
            stop = [CGPoint(x: horizontalCenter, y: round(screenHeight * 0.66))]
        case .swipeUp:
            viewCount = 1
            start = [CGPoint(x: horizontalCenter, y: round(screenHeight * 0.66))]
            stop = [CGPoint(x: horizontalCenter, y: round(screenHeight * 0.15))]
        case .swipeLeft:
            viewCount = 1
            start = [CGPoint(x: screenWidth * 0.8, y: round(screenHeight / 2.0))]
            stop = [CGPoint(x: screenWidth * 0.2, y: round(screenHeight / 2.0))]
        case .swipeRight:
            viewCount = 1
            start = [CGPoint(x: screenWidth * 0.2, y: round(screenHeight / 2.0))]
            stop = [CGPoint(x: screenWidth * 0.8, y: round(screenHeight / 2.0))]
        case .customSwipe:
            viewCount = 1
            start = startPoistions
            stop = endPoistions
        default:
            viewCount = 1
            start = startPoistions
            stop = startPoistions
        }
        
        let tapColor = GestureInstructor.appearance.tapColor
        GIView.appearance().backgroundColor = tapColor.withAlphaComponent(0.7)
        GIView.appearance().tintColor = tapColor
        
        var views = [GIView]()
        for _ in 0..<viewCount {
            let view = GIView(frame: .zero)
            view.image = GestureInstructor.appearance.tapImage
            views.append(view)
        }
        
        self.startPoistions = start
        self.endPoistions = stop
        self.views = views
        
        guard let descriptionLabel = descriptionLabel else { return }
        
        var animationRect = CGRect(x: CGFloat.greatestFiniteMagnitude, y: CGFloat.greatestFiniteMagnitude, width: 0, height: 0)
        for i in 0..<start.count {
            let p0 = start[i]
            let p1 = stop[i]
            animationRect.origin.x = 0
            animationRect.origin.y = min(animationRect.origin.y, min(p0.y, p1.y))
            animationRect.size.height = max(animationRect.size.height, max(p0.y, p1.y) - animationRect.origin.y)
            animationRect.size.width = screenWidth
        }
        
        var labelY: CGFloat = 0
        let labelMargin: CGFloat = 30
        let labelWidth: CGFloat = screenWidth * 0.7
        let textSize = descriptionLabel.attributedText?.boundingRect(with: CGSize(width: labelWidth, height: .greatestFiniteMagnitude), options: [.usesLineFragmentOrigin], context: nil).size ?? .zero
        let labelHeight: CGFloat = max(60, textSize.height + 6)
        
        let spaceBelow = screenHeight - animationRect.maxY + GIView.size.height - labelMargin
        if spaceBelow >= labelHeight {
            labelY = animationRect.maxY + GIView.size.height + labelMargin
        } else {
            labelY = max(screenTopMargin, animationRect.minY - labelMargin - labelHeight)
        }
        
        descriptionLabel.alpha = 0
        descriptionLabel.frame = CGRect(x: round((screenWidth - labelWidth)/2),
                                         y: round(labelY),
                                         width: round(labelWidth),
                                         height: round(labelHeight))
        window.addSubview(descriptionLabel)
    }
    
    private func centerPoint(for view: UIView) -> CGPoint {
        if let superView = view.superview {
            return superView.convert(view.center, to: nil)
        } else {
            return view.center
        }
    }
}

