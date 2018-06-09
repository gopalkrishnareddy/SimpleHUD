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

public struct Constants {
    static let horizontalHUDWidth: CGFloat = 280.0
    static let horizontalHUDHeight: CGFloat = 70.0
    static let verticalHUDWidth: CGFloat = 250.0
    static let verticalHUDHeight: CGFloat = 120.0
    static let cornerRadius: CGFloat = 20.0
    static let labelFont: CGFloat = 18.0
    static let stackViewSpacing: CGFloat = 10.0
}

class SHUD {
    private static let sharedInstance = SHUD()
    private static var imagesCache = [SHUDType: UIImage]()

    private lazy var containerView = UIView()
    private lazy var hudView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
    private lazy var stackView = UIStackView()
    private lazy var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    private lazy var label = UILabel()
    private lazy var imageView = UIImageView()
    
    private var widthAnchor: NSLayoutConstraint?
    private var heightAnchor: NSLayoutConstraint?
    private var hostView: UIView?
    private var stackViewVerticalAlignmentConstraints = [NSLayoutConstraint]()

    private var style: SHUDStyle = .dark {
        willSet {
            if style != newValue {
                SHUD.imagesCache = [:]
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
                if self.alignment == .vertical {
                    self.stackView.axis = .vertical
                    self.label.textAlignment = .center
                    self.stackViewVerticalAlignmentConstraints.forEach { $0.isActive = true }
                } else {
                    self.stackView.axis = .horizontal
                    self.label.textAlignment = .left
                    self.stackViewVerticalAlignmentConstraints.forEach { $0.isActive = false }
                }
            }
        }
    }
    
    private var color: UIColor {
        return self.style == .light ? .black : .white
    }
    
    private var backgroundColor: UIColor {
        return self.style == .light ? UIColor(white: 0.6, alpha: 0.7) : UIColor(white: 0.8, alpha: 0.7)
    }

    private var size: CGSize {
        switch self.alignment {
        case .horizontal:
            return CGSize(width: Constants.horizontalHUDWidth, height: Constants.horizontalHUDHeight)
        case .vertical:
            return CGSize(width: Constants.verticalHUDWidth, height: Constants.verticalHUDHeight)
        }
    }

    private init() {
        configureContainerView()
        configureHUDView()
        configureSubviews()
    }

    fileprivate func configureContainerView() {
        guard let window = UIApplication.shared.windows.first else { return }
        containerView.frame = window.bounds
        containerView.isUserInteractionEnabled = false
        containerView.backgroundColor = backgroundColor
    }
    
    fileprivate func configureHUDView() {
        hudView.translatesAutoresizingMaskIntoConstraints = false
        hudView.layer.cornerRadius = Constants.cornerRadius
        hudView.clipsToBounds = true
        containerView.addSubview(hudView)
        hudView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        hudView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        
        widthAnchor = hudView.widthAnchor.constraint(equalToConstant: size.width)
        widthAnchor?.isActive = true
        if self.alignment == .vertical {
            heightAnchor = hudView.heightAnchor.constraint(greaterThanOrEqualToConstant: size.height)
        } else {
            heightAnchor = hudView.heightAnchor.constraint(equalToConstant: size.height)
        }
        heightAnchor?.isActive = true

    }
    
    fileprivate func configureSubviews() {
        let contentView = hudView.contentView
        contentView.addSubview(activityIndicator)
        contentView.addSubview(imageView)
        
        activityIndicator.hidesWhenStopped = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        label.numberOfLines = self.alignment == .vertical ? 0 : 1
        label.font = .systemFont(ofSize: Constants.labelFont)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.spacing = Constants.stackViewSpacing
        stackView.addArrangedSubview(activityIndicator)
        stackView.addArrangedSubview(label)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)
        
        stackView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        stackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        self.stackViewVerticalAlignmentConstraints.append(stackView.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: 15.0))
        self.stackViewVerticalAlignmentConstraints.append(stackView.trailingAnchor.constraint(greaterThanOrEqualTo: contentView.trailingAnchor, constant: -15.0))
        self.stackViewVerticalAlignmentConstraints.append(stackView.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor, constant: 15.0))
        self.stackViewVerticalAlignmentConstraints.append(stackView.bottomAnchor.constraint(greaterThanOrEqualTo: contentView.bottomAnchor, constant: -15.0))

        imageView.widthAnchor.constraint(equalTo: activityIndicator.widthAnchor).isActive = true
        imageView.heightAnchor.constraint(equalTo: activityIndicator.heightAnchor).isActive = true
        imageView.centerXAnchor.constraint(equalTo: activityIndicator.centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: activityIndicator.centerYAnchor).isActive = true
    }
    
    fileprivate func configureHUD(forType type: SHUDType) {
        DispatchQueue.main.async {
            var imageViewAlpha: CGFloat = 0.0
            var activityIndicatorAlpha: CGFloat = 0.0
            var shouldHideActivityIndicator: Bool = false
            self.activityIndicator.stopAnimating()
            switch type {
            case .loading:
                activityIndicatorAlpha = 1.0
                self.activityIndicator.startAnimating()
            case .none:
                shouldHideActivityIndicator = true
            case .success, .error, .info:
                imageViewAlpha = 1.0
            }
            self.activityIndicator.isHidden = shouldHideActivityIndicator
            self.activityIndicator.alpha = activityIndicatorAlpha
            self.imageView.alpha = imageViewAlpha
            self.imageView.image = SHUD.image(type)
        }
    }
    
    fileprivate func updateText(_ text: String) {
        DispatchQueue.main.async {
            self.label.isHidden = false
            self.label.alpha = 0.0
            UIView.animate(withDuration: 0.3) {
                self.label.alpha = 1.0
                self.label.text = text
            }
        }
    }
    
    // MARK: - Images
    static func image(_ type: SHUDType) -> UIImage? {
        guard let image = imagesCache[type] else {
            var newImage: UIImage? = nil
            switch type {
            case .success:
                newImage = .draw(.checkmark, color: SHUD.sharedInstance.color)
            case .error:
                newImage = .draw(.crossmark, color: SHUD.sharedInstance.color)
            case .info:
                newImage = .draw(.warning, color: SHUD.sharedInstance.color)
            default:
                break
            }
            imagesCache[type] = newImage
            return newImage
        }
        return image

    }

    // MARK: - Orientation Notifications and Related Methods
    fileprivate func registerDeviceOrientationNotification() {
        NotificationCenter.default.addObserver(SHUD.sharedInstance, selector: #selector(SHUD.handleOrientationChange(_:)), name: NSNotification.Name.UIApplicationDidChangeStatusBarOrientation, object: nil)
    }
    
    fileprivate func removeDeviceOrientationNotification() {
        NotificationCenter.default.removeObserver(SHUD.sharedInstance)
    }
    
    @objc fileprivate func handleOrientationChange(_ notification: Notification) {
        if let hostView = hostView {
            containerView.frame = hostView.bounds
        } else if let window = UIApplication.shared.windows.first {
            containerView.frame = window.bounds
        }
    }
    
}

extension UIImage {
    enum Shape {
        case checkmark
        case crossmark
        case warning
    }
    
    // drawing logic part is taken from https://github.com/Chakery/HUD
    class func draw(_ shape: Shape, color: UIColor) -> UIImage? {
        defer {
            UIGraphicsEndImageContext()
        }
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 36, height: 36), false, 0)

        let checkmarkShapePath = UIBezierPath()
        // draw circle
        checkmarkShapePath.move(to: CGPoint(x: 36, y: 18))
        checkmarkShapePath.addArc(withCenter: CGPoint(x: 18, y: 18), radius: 17.5, startAngle: 0, endAngle: .pi * 2, clockwise: true)
        checkmarkShapePath.close()
        
        switch shape {
        case .checkmark: // draw checkmark
            checkmarkShapePath.move(to: CGPoint(x: 10, y: 18))
            checkmarkShapePath.addLine(to: CGPoint(x: 16, y: 24))
            checkmarkShapePath.addLine(to: CGPoint(x: 27, y: 13))
            checkmarkShapePath.move(to: CGPoint(x: 10, y: 18))
            checkmarkShapePath.close()
        case .crossmark: // draw X
            checkmarkShapePath.move(to: CGPoint(x: 10, y: 10))
            checkmarkShapePath.addLine(to: CGPoint(x: 26, y: 26))
            checkmarkShapePath.move(to: CGPoint(x: 10, y: 26))
            checkmarkShapePath.addLine(to: CGPoint(x: 26, y: 10))
            checkmarkShapePath.move(to: CGPoint(x: 10, y: 10))
            checkmarkShapePath.close()
        case .warning: // draw info icon
            checkmarkShapePath.move(to: CGPoint(x: 18, y: 6))
            checkmarkShapePath.addLine(to: CGPoint(x: 18, y: 22))
            checkmarkShapePath.move(to: CGPoint(x: 18, y: 6))
            checkmarkShapePath.close()
            
            color.setStroke()
            checkmarkShapePath.stroke()
            
            let checkmarkShapePath = UIBezierPath()
            checkmarkShapePath.move(to: CGPoint(x: 18, y: 27))
            checkmarkShapePath.addArc(withCenter: CGPoint(x: 18, y: 27), radius: 1, startAngle: 0, endAngle: .pi * 2, clockwise: true)
            checkmarkShapePath.close()
            
            color.setFill()
            checkmarkShapePath.fill()
        }
        color.setStroke()
        checkmarkShapePath.stroke()
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}

struct Delay {
    public static func by(time: Double, closure: @escaping () -> Swift.Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + time) {
            closure()
        }
    }
}

extension SHUD {
    open static func show(_ onView: UIView? = nil, style: SHUDStyle = .dark, alignment: SHUDAlignment = .vertical, type: SHUDType = .loading, text: String?, _ completion: (() -> Swift.Void)? = nil) {
        let hud = SHUD.sharedInstance
        hud.style = style
        hud.alignment = alignment
        hud.hostView = onView
        hud.registerDeviceOrientationNotification()
        hud.label.numberOfLines = alignment == .vertical ? 0 : 1

        hud.configureHUD(forType: type)
        if let text = text {
            hud.updateText(text)
            hud.label.isHidden = false
        } else {
            hud.label.isHidden = true
        }

        guard hud.containerView.superview != nil else {
            if let hostView = hud.hostView {
                hostView.isUserInteractionEnabled = false
                hud.containerView.frame = hostView.bounds
                hostView.addSubview(hud.containerView)
            } else {
                guard let window = UIApplication.shared.windows.first else { return }
                window.addSubview(hud.containerView)
                window.isUserInteractionEnabled = false
            }
            
            hud.hudView.alpha = 0.0
            hud.hudView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            UIView.animate(withDuration: 0.3, animations: {
                hud.hudView.alpha = 1.0
                hud.hudView.transform = .identity
            }) { _ in
                completion?()
            }
            return
        }
        completion?()
    }
    
    open static func updateHUDText(_ text: String) {
        let hud = SHUD.sharedInstance
        hud.updateText(text)
    }
    
    open static func hide(_ completion: (() -> Swift.Void)? = nil) {
        let hud = SHUD.sharedInstance
        guard hud.containerView.superview != nil else { return }
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.3, animations: {
                hud.containerView.alpha = 0.0
                hud.hudView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            }){ _ in
                hud.containerView.superview?.isUserInteractionEnabled = true
                hud.containerView.alpha = 1.0
                hud.containerView.removeFromSuperview()
                hud.hudView.transform = .identity
                hud.label.text = nil
                hud.imageView.image = nil
                hud.removeDeviceOrientationNotification()
                hud.hostView?.isUserInteractionEnabled = true
                completion?()
            }
        }
    }
    
    open static func hide(success: Bool = true, text: String? = nil, _ completion: (() -> Swift.Void)? = nil) {
        let hud = SHUD.sharedInstance
        hud.configureHUD(forType: success ? .success : .error)
        if let text = text {
            hud.updateText(text)
        }
        DispatchQueue.main.async {
            Delay.by(time: 1.0) {
                hide(completion)
            }
        }
    }
}

extension UIViewController {
    open func showHUD(style: SHUDStyle = .dark, alignment: SHUDAlignment = .horizontal, type: SHUDType = .loading, text: String? = nil, _ completion: (() -> Swift.Void)? = nil) {
        SHUD.show(self.view, style: style, alignment: alignment, type: type, text: text, completion)
    }

    open func hideHUD(_ completion: (() -> Swift.Void)? = nil) {
        SHUD.hide(completion)
    }
    
    open func updateHUDText(_ text: String) {
        SHUD.updateHUDText(text)
    }
    
    open func hideHUD(success: Bool = true, text: String?, _ completion: (() -> Swift.Void)? = nil) {
        SHUD.hide(success: success, text: text, completion)
    }
}
