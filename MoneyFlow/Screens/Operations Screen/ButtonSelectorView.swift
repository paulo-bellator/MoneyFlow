//
//  ButtonSelectorView.swift
//  MoneyFlow
//
//  Created by Никита Гончаров on 07/10/2019.
//  Copyright © 2019 Никита Гончаров. All rights reserved.
//

import UIKit

protocol ButtonSelectorViewDelegate: class {
    func buttonSelectorOpened(sender: ButtonSelectorView, animated: Bool)
    func buttonSelectorClosed(sender: ButtonSelectorView, animated: Bool)
}

class ButtonSelectorView: UIView {
    
    weak var delegate: ButtonSelectorViewDelegate?
    var direction: Direction = .up { didSet { if oldValue != direction { rotate(direction) } } }
    
    private(set) var isOpen: Bool = false
    private(set) var buttons = [UIButton]()
    
    lazy var mainButton: UIButton = {
        let button = UIButton(frame: frame)
        button.addTarget(self, action: #selector(mainButtonTouched), for: .touchUpInside)
        button.backgroundColor = .clear
        if let image = UIImage(named: "plus_icon.png") {
            button.setImage(image, for: .normal)
        }
        self.addSubview(button)
        return button
    }()
    
    // MARK: Animating open/close
    
    @objc private func mainButtonTouched() {
        if bounds.width.rounded() == bounds.height.rounded() {
            open(animated: true)
        } else {
            close(animated: true)
        }
    }
    
    func open(animated: Bool) {
        if animated {
            UIView.animate(
                withDuration: 0.2,
                delay: 0,
                options: .curveEaseOut,
                animations: {
                    self.bounds.size.height = self.bounds.size.width * CGFloat((self.buttons.count + 1))
                    self.mainButton.transform = CGAffineTransform.init(rotationAngle: CGFloat.pi / 4 + CGFloat.pi/2)
                    self.compenstateOffset()
                    self.layoutIfNeeded()
                },
                completion: { _ in
                    UIView.animate(withDuration: 0.1) {
                        self.buttons.forEach { $0.alpha = 1.0; $0.isHidden = false }
                    }
            })
        } else {
            self.bounds.size.height = self.bounds.size.width * CGFloat((self.buttons.count + 1))
            self.mainButton.transform = CGAffineTransform.init(rotationAngle: CGFloat.pi / 4 + CGFloat.pi/2)
            self.compenstateOffset()
            self.buttons.forEach { $0.alpha = 1.0; $0.isHidden = false }
            self.layoutIfNeeded()
        }
        isOpen = true
        delegate?.buttonSelectorOpened(sender: self, animated: animated)
    }
    
    func close(animated: Bool) {
        if animated {
            UIView.animate(
                withDuration: 0.05,
                animations: {
                    self.buttons.forEach { $0.alpha = 0.0}
            },
                completion: { _ in
                    self.buttons.forEach { $0.isHidden = true}
                    UIView.animate(withDuration: 0.2) {
                        self.bounds.size.height = self.bounds.size.width
                        self.compenstateOffset()
                        self.mainButton.transform = .identity
                        self.layoutIfNeeded()
                    }
            })
        } else {
            self.buttons.forEach { $0.alpha = 0.0; $0.isHidden = true }
            self.bounds.size.height = self.bounds.size.width
            self.compenstateOffset()
            self.mainButton.transform = .identity
            self.layoutIfNeeded()
        }
        isOpen = false
        delegate?.buttonSelectorClosed(sender: self, animated: animated)
    }
    
    // MARK: Initialization and layouting
    
    private func initialization() {
        buttons.forEach { $0.alpha = 0.0; $0.isHidden = true }
        addMainButtonConstraints()
        addUserButtonsConstraints()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.width/2
        buttons.forEach { $0.layer.cornerRadius = $0.bounds.width/2  }
        mainButton.layer.cornerRadius = bounds.width/2
        addShadow()
    }
    
    convenience init(frame: CGRect, button1: UIButton, button2: UIButton, button3: UIButton? = nil) {
        self.init(frame: frame)
        if let button3 = button3 { self.buttons.append(button3) }
        self.buttons.append(button2)
        self.buttons.append(button1)
        buttons.forEach { self.addSubview($0) }
        initialization()
    }
    
    override private init(frame: CGRect) {
        let sideSize = min(frame.width, frame.height)
        let size = CGSize(width: sideSize, height: sideSize)
        let quadFrame = CGRect(origin: frame.origin, size: size)
        super.init(frame: quadFrame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Adding constraints
    
    private func addUserButtonsConstraints() {
        guard !buttons.isEmpty else { return }
        
        for (index, button) in buttons.enumerated() {
            button.constraints.forEach { button.removeConstraint($0) }
            var topConstraint: NSLayoutConstraint
            
            if index < buttons.count - 1 {
                topConstraint = NSLayoutConstraint(item: button, attribute: .top, relatedBy: .equal, toItem: buttons[index+1], attribute: .bottom, multiplier: 1, constant: 0)
            } else {
                topConstraint = NSLayoutConstraint(item: button, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0)
            }
            let centerConstraint = NSLayoutConstraint(item: button, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0)
            let widthConstraint = NSLayoutConstraint(item: button, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 1, constant: 0)
            let heightConstraint = NSLayoutConstraint(item: button, attribute: .height, relatedBy: .equal, toItem: button, attribute: .width, multiplier: 1, constant: 0)
            self.addConstraints([topConstraint, centerConstraint, widthConstraint, heightConstraint])
            button.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    private func addMainButtonConstraints() {
        mainButton.constraints.forEach { mainButton.removeConstraint($0) }
        let centerConstraint = NSLayoutConstraint(item: mainButton, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0)
        let widthConstraint = NSLayoutConstraint(item: mainButton, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 1, constant: 0)
        let heightConstraint = NSLayoutConstraint(item: mainButton, attribute: .height, relatedBy: .equal, toItem: mainButton, attribute: .width, multiplier: 1, constant: 0)
        let bottomConstraint = NSLayoutConstraint(item: mainButton, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: -frame.width/2)
        self.addConstraints([bottomConstraint, centerConstraint, widthConstraint, heightConstraint])
        mainButton.translatesAutoresizingMaskIntoConstraints = false
    }
    
    // MARK: Service funcs
    
    private func compenstateOffset() {
        var offset = bounds.width * CGFloat(buttons.count)
        if bounds.width.rounded() != bounds.height.rounded() {
            offset *= -1
        }
        switch direction {
        case .up:
            self.frame.origin.y += (offset)/2
        case .down:
            self.frame.origin.y -= (offset)/2
        case .left:
            self.frame.origin.x += (offset)/2
        case .right:
            self.frame.origin.x -= (offset)/2
        }
    }
    
    private func rotate(_ direction: Direction) {
        self.transform = .identity
        buttons.forEach { $0.transform = .identity }
        switch direction {
        case .up: break
        case .down:
            self.transform = CGAffineTransform.init(rotationAngle: CGFloat.pi)
            buttons.forEach { $0.transform = CGAffineTransform.init(rotationAngle: -CGFloat.pi)}
        case .left:
            self.transform = CGAffineTransform.init(rotationAngle: -CGFloat.pi/2)
            buttons.forEach { $0.transform = CGAffineTransform.init(rotationAngle: CGFloat.pi/2)}
        case .right:
            self.transform = CGAffineTransform.init(rotationAngle: +CGFloat.pi/2)
            buttons.forEach { $0.transform = CGAffineTransform.init(rotationAngle: -CGFloat.pi/2)}
        }
    }
    
    private func addShadow() {
        let radius = bounds.width / 2
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowPath = UIBezierPath(roundedRect:bounds, byRoundingCorners:[.topLeft, .topRight, .bottomLeft, .bottomRight], cornerRadii: CGSize(width: radius, height:  radius)).cgPath
        layer.shadowOffset = .zero
        layer.shadowOpacity = 0.3
        layer.shadowRadius = radius
    }
    
    enum Direction { case up, down, left, right }
}

private extension UIView {
    func addRoundedRectMask() {
        let radius = frame.width / 2
        let path = UIBezierPath(
            roundedRect: bounds,
            byRoundingCorners: [.topLeft, .topRight, .bottomRight, .bottomLeft],
            cornerRadii: CGSize(width: radius, height: radius))
        let shape = CAShapeLayer()
        shape.path = path.cgPath
        layer.mask = shape
    }
}

