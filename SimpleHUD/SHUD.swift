//
//  SHUD.swift
//
//  Created by Gopal Krishna Reddy on 17/03/18.
//  Copyright © 2018 Gopal Krishna Reddy. All rights reserved.
//

import Foundation
import UIKit

public enum SHUDType {
    case loading
    case success
    case error
    case info
    case none
}

public enum SHUDStyle {
    case light
    case dark
}

public enum SHUDAlignment {
    case horizontal
    case vertical
}

class SHUD {
    private static let sharedInstance = SHUD()
   
    private lazy var containerView = UIView()
    private lazy var containerBlurView = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
    private lazy var hudView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
    private lazy var stackView = UIStackView()
    private lazy var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    private lazy var label = UILabel()
    private lazy var imageView = UIImageView()
    
    private var widthAnchor: NSLayoutConstraint?
    private var heightAnchor: NSLayoutConstraint?
    private var hostView: UIView?

    private var style: SHUDStyle = .dark {
        willSet {
            if style != newValue {
                ImageCache.checkmarkImage = nil
                ImageCache.crossmarkImage = nil
                ImageCache.infoImage = nil
            }
        }
        didSet {
            DispatchQueue.main.async {
                self.hudView.effect = UIBlurEffect(style: self.style == .light ? .light : .dark)
                self.activityIndicator.color = self.color
                self.label.textColor = self.color
                self.containerView.backgroundColor = self.backgroundColor
            }
        }
    }

    private var alignment: SHUDAlignment = .vertical {
        didSet {
            DispatchQueue.main.async {
                self.widthAnchor?.constant = self.size.width
                self.heightAnchor?.constant = self.size.height
                self.stackView.axis = self.alignment == .vertical ? .vertical : .horizontal
                self.label.textAlignment = self.alignment == .vertical ? .center : .left
            }
        }
    }
    
    private var color: UIColor {
        return self.style == .light ? .black : .white
    }
    
    private var backgroundColor: UIColor {
        return self.style == .light ? UIColor(white: 0.3, alpha: 0.5) : UIColor(white: 0.8, alpha: 0.5)
    }

    private var size: CGSize {
        switch self.alignment {
        case .horizontal:
            return CGSize(width: 280.0, height: 70.0)
        case .vertical:
            return CGSize(width: 250.0, height: 120.0)
        }
    }
    
    static func image(_ type: SHUDType) -> UIImage? {
        switch type {
        case .success:
            return checkmarkImage
        case .error:
            return crossmarkImage
        case .info:
            return infoImage
        default:
            return nil
        }
    }
    
    private struct ImageCache {
        static var checkmarkImage: UIImage?
        static var crossmarkImage: UIImage?
        static var infoImage: UIImage?
    }
    
    private init() {
        configureContainerView()
        configureHUDView()
        configureSubviews()
    }
    
    fileprivate func registerDeviceOrientationNotification() {
        NotificationCenter.default.addObserver(SHUD.sharedInstance, selector: #selector(SHUD.updateHUD(_:)), name: NSNotification.Name.UIApplicationDidChangeStatusBarOrientation, object: nil)
    }
    
    fileprivate func removeDeviceOrientationNotification() {
        NotificationCenter.default.removeObserver(SHUD.sharedInstance)
    }
    
    @objc fileprivate func updateHUD(_ notification: Notification) {
        defer {
            containerBlurView.frame = containerView.bounds
        }
        if let hostView = hostView {
            containerView.frame = hostView.bounds
        } else {
            guard let window = UIApplication.shared.windows.first else { return }
            containerView.frame = window.bounds
        }
    }
    
    private func configureContainerView() {
        guard let window = UIApplication.shared.windows.first else { return }
        containerView.frame = window.bounds
        containerView.isUserInteractionEnabled = false
        containerView.backgroundColor = backgroundColor
    }
    
    private func configureHUDView() {
        hudView.translatesAutoresizingMaskIntoConstraints = false
        hudView.layer.cornerRadius = 20.0
        hudView.clipsToBounds = true
        containerView.addSubview(hudView)
        hudView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        hudView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        
        widthAnchor = hudView.widthAnchor.constraint(equalToConstant: size.width)
        widthAnchor?.isActive = true
        
        heightAnchor = hudView.heightAnchor.constraint(equalToConstant: size.height)
        heightAnchor?.isActive = true

    }
    
    private func configureSubviews() {
        let contentView = hudView.contentView
        contentView.addSubview(activityIndicator)
        contentView.addSubview(imageView)
        
        activityIndicator.hidesWhenStopped = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 20.0)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.spacing = 10.0
        stackView.addArrangedSubview(activityIndicator)
        stackView.addArrangedSubview(label)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)
        
        stackView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        stackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        
        imageView.widthAnchor.constraint(equalTo: activityIndicator.widthAnchor).isActive = true
        imageView.heightAnchor.constraint(equalTo: activityIndicator.heightAnchor).isActive = true
        imageView.centerXAnchor.constraint(equalTo: activityIndicator.centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: activityIndicator.centerYAnchor).isActive = true
    }

    public static func show(_ onView: UIView? = nil, style: SHUDStyle = .dark, alignment: SHUDAlignment = .horizontal, type: SHUDType = .loading, text: String? = "Loading...", _ completion: (() -> Swift.Void)? = nil) {
        let hud = SHUD.sharedInstance
        hud.style = style
        hud.alignment = alignment
        hud.hostView = onView
        hud.registerDeviceOrientationNotification()
        
        DispatchQueue.main.async {
            if let hostView = hud.hostView {
                hostView.isUserInteractionEnabled = false
                hud.containerView.frame = hostView.bounds
                hostView.addSubview(hud.containerView)
            } else {
                guard let window = UIApplication.shared.windows.first else { return }
                window.addSubview(hud.containerView)
            }
            
            if hud.label.text != nil {
                hud.label.alpha = 0.0
                UIView.animate(withDuration: 0.3, animations: {
                    hud.label.alpha = 1.0
                    hud.label.text = text
                }) { _ in
                    completion?()
                }
            } else {
                hud.hudView.alpha = 0.0
                hud.hudView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                UIView.animate(withDuration: 0.3, animations: {
                    hud.hudView.alpha = 1.0
                    hud.hudView.transform = .identity
                }) { _ in
                    completion?()
                }
                hud.label.text = text
            }
            switch type {
            case .loading:
                hud.activityIndicator.isHidden = false
                hud.activityIndicator.startAnimating()
                hud.activityIndicator.alpha = 1.0
                hud.imageView.image = nil
                hud.imageView.alpha = 0.0
            case .none:
                hud.activityIndicator.isHidden = true
                hud.activityIndicator.stopAnimating()
                hud.activityIndicator.alpha = 0.0
                hud.imageView.image = nil
                hud.imageView.alpha = 0.0
            case .success, .error, .info:
                hud.activityIndicator.isHidden = false
                hud.activityIndicator.stopAnimating()
                hud.activityIndicator.alpha = 0.0
                hud.imageView.alpha = 1.0
                hud.imageView.image = SHUD.image(type)
            }
        }
    }
    
    public static func hide(_ completion: (() -> Swift.Void)? = nil) {
        let hud = SHUD.sharedInstance
        DispatchQueue.main.async {
            guard hud.containerView.superview != nil else { return }
            UIView.animate(withDuration: 0.3, animations: {
                hud.containerView.alpha = 0.0
                hud.hudView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            }){ _ in
                hud.containerView.alpha = 1.0
                hud.hudView.transform = .identity
                hud.label.text = nil
                hud.imageView.image = nil
                hud.containerView.removeFromSuperview()
                hud.removeDeviceOrientationNotification()
                hud.hostView?.isUserInteractionEnabled = true
                completion?()
            }
        }
    }
    
    public static func hide(success: Bool = true, text: String?, _ completion: (() -> Swift.Void)? = nil) {
        let hud = SHUD.sharedInstance
        hud.removeDeviceOrientationNotification()
        SHUD.show(hud.hostView, style: hud.style, alignment: hud.alignment, type: success ? .success : .error, text: text) {
            DispatchQueue.main.async {
                Delay.by(time: 0.8) {
                    hide(completion)
                }
            }
        }
    }
    
    fileprivate class var checkmarkImage: UIImage {
        guard let checkmarkImage = ImageCache.checkmarkImage else {
            UIGraphicsBeginImageContextWithOptions(CGSize(width: 36, height: 36), false, 0)
            SHUD.draw(.success)
            ImageCache.checkmarkImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return ImageCache.checkmarkImage!
        }
        return checkmarkImage
    }
    
    fileprivate class var crossmarkImage: UIImage {
        guard let crossmarkImage = ImageCache.crossmarkImage else {
            UIGraphicsBeginImageContextWithOptions(CGSize(width: 36, height: 36), false, 0)
            SHUD.draw(.error)
            ImageCache.crossmarkImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return ImageCache.crossmarkImage!
        }
        return crossmarkImage
    }
    
    fileprivate class var infoImage: UIImage {
        guard let infoImage = ImageCache.infoImage else {
            UIGraphicsBeginImageContextWithOptions(CGSize(width: 36, height: 36), false, 0)
            SHUD.draw(.info)
            ImageCache.infoImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return ImageCache.infoImage!
        }
        return infoImage
    }
    
    // draw
    private class func draw(_ type: SHUDType) {
        let checkmarkShapePath = UIBezierPath()
        // draw circle
        checkmarkShapePath.move(to: CGPoint(x: 36, y: 18))
        checkmarkShapePath.addArc(withCenter: CGPoint(x: 18, y: 18), radius: 17.5, startAngle: 0, endAngle: .pi * 2, clockwise: true)
        checkmarkShapePath.close()
        
        switch type {
        case .success: // draw checkmark
            checkmarkShapePath.move(to: CGPoint(x: 10, y: 18))
            checkmarkShapePath.addLine(to: CGPoint(x: 16, y: 24))
            checkmarkShapePath.addLine(to: CGPoint(x: 27, y: 13))
            checkmarkShapePath.move(to: CGPoint(x: 10, y: 18))
            checkmarkShapePath.close()
        case .error: // draw X
            checkmarkShapePath.move(to: CGPoint(x: 10, y: 10))
            checkmarkShapePath.addLine(to: CGPoint(x: 26, y: 26))
            checkmarkShapePath.move(to: CGPoint(x: 10, y: 26))
            checkmarkShapePath.addLine(to: CGPoint(x: 26, y: 10))
            checkmarkShapePath.move(to: CGPoint(x: 10, y: 10))
            checkmarkShapePath.close()
        case .info: // draw info icon
            checkmarkShapePath.move(to: CGPoint(x: 18, y: 6))
            checkmarkShapePath.addLine(to: CGPoint(x: 18, y: 22))
            checkmarkShapePath.move(to: CGPoint(x: 18, y: 6))
            checkmarkShapePath.close()
            
            SHUD.sharedInstance.color.setStroke()
            checkmarkShapePath.stroke()
            
            let checkmarkShapePath = UIBezierPath()
            checkmarkShapePath.move(to: CGPoint(x: 18, y: 27))
            checkmarkShapePath.addArc(withCenter: CGPoint(x: 18, y: 27), radius: 1, startAngle: 0, endAngle: .pi * 2, clockwise: true)
            checkmarkShapePath.close()
            
            SHUD.sharedInstance.color.setFill()
            checkmarkShapePath.fill()
        default: break
        }
        
        SHUD.sharedInstance.color.setStroke()
        checkmarkShapePath.stroke()
    }
    
}

struct Delay {
    public static func by(time: Double, closure: @escaping ()->()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + time) {
            closure()
        }
    }
}

extension UIView {
    open func showHUD(style: SHUDStyle = .dark, alignment: SHUDAlignment = .horizontal, type: SHUDType = .loading, text: String, _ completion: (() -> Swift.Void)? = nil) {
        SHUD.show(self, style: style, alignment: alignment, type: type, text: text, completion)
    }
    
    open func hideHUD(_ completion: (() -> Swift.Void)? = nil) {
        SHUD.hide(completion)
    }
    
    open func hideHUD(success: Bool = true, text: String?, _ completion: (() -> Swift.Void)? = nil) {
        SHUD.hide(success: success, text: text, completion)
    }
}

extension UIViewController {
    open func showHUD(style: SHUDStyle = .dark, alignment: SHUDAlignment = .horizontal, type: SHUDType = .loading, text: String, _ completion: (() -> Swift.Void)? = nil) {
        view.showHUD(style: style, alignment: alignment, type: type, text: text, completion)
    }
    
    open func hide(_ completion: (() -> Swift.Void)? = nil) {
        view.hideHUD(completion)
    }
    
    open func hide(success: Bool = true, text: String?, _ completion: (() -> Swift.Void)? = nil) {
        view.hideHUD(success: success, text: text, completion)
    }
}
