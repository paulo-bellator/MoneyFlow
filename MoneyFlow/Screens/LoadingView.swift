//
//  LoadingView.swift
//  MoneyFlow
//
//  Created by Никита Гончаров on 14/10/2019.
//  Copyright © 2019 Никита Гончаров. All rights reserved.
//

import UIKit

class LoadingView: UIView {
    
    var shouldAnimateLoaderIcon = true {
        didSet {
            if shouldAnimateLoaderIcon == false && oldValue == true {
                stopAnimating()
                loaderIconImageView.transform = .identity
            }
        }
    }
    
    var shouldApperBreakButton = true {
        didSet {
            if breakButton.isHidden == false { breakButton.isHidden.toggle() }
        }
    }
    
    lazy var breakAction: (() -> Void) = { [weak self] in self?.remove() }
    
    private(set) lazy var loaderIconImageView: UIImageView = {
        let imageView = UIImageView()
        if let image = UIImage(named: "loader_icon.png") {
            imageView.image = image
        }
        self.addSubview(imageView)
        return imageView
    }()
    
    private(set) lazy var mainLabel: UILabel = {
        let label = UILabel()
        label.text = "Загрузка"
        label.textAlignment = .center
        label.textColor = .black
        label.font = Constants.labelFont
        self.addSubview(label)
        return label
    }()
    
    private(set) lazy var breakButton: UIButton = {
        let button = UIButton()
        let label = UILabel()
        button.setTitle("Прервать", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = Constants.buttonFont
        button.addTarget(self, action: #selector(breakButtonTouched), for: .touchUpInside)
        self.addSubview(button)
        return button
    }()
    
    // MARK: API
    
    func startAnimating() {
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0.0
        rotateAnimation.toValue = -CGFloat.pi * 2
        rotateAnimation.isRemovedOnCompletion = false
        rotateAnimation.duration = 2
        rotateAnimation.repeatCount = .infinity
        loaderIconImageView.layer.add(rotateAnimation, forKey: Constants.rotateAnimationKey)
    }
    
    func stopAnimating() {
        loaderIconImageView.layer.removeAnimation(forKey: Constants.rotateAnimationKey)
    }
    
    func remove(animated: Bool = true, duration: TimeInterval = 0.2) {
        mainLabel.isHidden = true
        loaderIconImageView.isHidden = true
        breakButton.isHidden = true
        if animated {
            UIView.animate(
                withDuration: duration,
                animations: { [weak self] in
                    self?.alpha = 0.0
                }, completion: { [weak self] _ in
                    self?.stopAnimating()
                    self?.removeFromSuperview()
            })
        } else {
            stopAnimating()
            removeFromSuperview()
        }
    }
    
    func appear(animated: Bool = true, duration: TimeInterval = 0.2) {
        if !animated {
            if shouldAnimateLoaderIcon { startAnimating() }
            alpha = 1.0
            mainLabel.isHidden = false
            loaderIconImageView.isHidden = false
            breakButton.isHidden = !shouldApperBreakButton
            return
        }
        
        alpha = 0.0
        mainLabel.isHidden = true
        loaderIconImageView.isHidden = true
        breakButton.isHidden = true
        
        UIView.animate(
            withDuration: duration,
            animations: { [weak self] in
                self?.alpha = 1.0
            }, completion: { [weak self] _ in
                if self != nil {
                    if self!.shouldAnimateLoaderIcon { self!.startAnimating() }
                    self!.mainLabel.isHidden = false
                    self!.loaderIconImageView.isHidden = false
                    if self!.shouldApperBreakButton { self!.breakButton.isHidden = false }
                }
        })
    }
    
    @objc func breakButtonTouched() {
        breakAction()
    }

    // MARK: Initialization and layouting
    
    private func initialize() {
        alpha = 0.0
        mainLabel.isHidden = true
        loaderIconImageView.isHidden = true
        breakButton.isHidden = true
        
        frame = UIScreen.main.bounds
        backgroundColor = UIColor.white.withAlphaComponent(0.98)
        setConstraints()
    }
    
    convenience init(superView: UIView) {
        self.init(frame: CGRect.zero)
        superView.addSubview(self)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func setConstraints() {
        self.constraints.forEach { self.removeConstraint($0) }
        
        // loaderIcon
        let centerXConstraintIcon = NSLayoutConstraint(item: loaderIconImageView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0)
        let centerYConstraintIcon = NSLayoutConstraint(item: loaderIconImageView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: -40)
        let widthConstraintIcon = NSLayoutConstraint(item: loaderIconImageView, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 0.10, constant: 0)
        let heightConstraintIcon = NSLayoutConstraint(item: loaderIconImageView, attribute: .height, relatedBy: .equal, toItem: loaderIconImageView, attribute: .width, multiplier: 1, constant: 0)
        self.addConstraints([centerXConstraintIcon, centerYConstraintIcon, widthConstraintIcon, heightConstraintIcon])
        loaderIconImageView.translatesAutoresizingMaskIntoConstraints = false
        
        // mainLabel
        let topConstraintLabel = NSLayoutConstraint(item: mainLabel, attribute: .top, relatedBy: .equal, toItem: loaderIconImageView, attribute: .bottom, multiplier: 1, constant: 30)
        let leadingConstraintLabel = NSLayoutConstraint(item: mainLabel, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 20)
        let trailingConstraintLabel = NSLayoutConstraint(item: mainLabel, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: -20)
        self.addConstraints([topConstraintLabel, leadingConstraintLabel, trailingConstraintLabel])
        mainLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // breakButton
        let bottomConstraintButton = NSLayoutConstraint(item: breakButton, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: -50)
        let centerXConstraintButton = NSLayoutConstraint(item: breakButton, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0)
        self.addConstraints([bottomConstraintButton, centerXConstraintButton])
        breakButton.translatesAutoresizingMaskIntoConstraints = false
    }
    
}

private extension LoadingView {
    private struct Constants {
        static let labelFont = UIFont(name: "CenturyGothic", size: 18.0)
        static let buttonFont = UIFont(name: "CenturyGothic", size: 15.0)
        static let rotateAnimationKey = "rotateAnim"
    }
}
