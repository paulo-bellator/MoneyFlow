//
//  EmptyViewController.swift
//  MoneyFlow
//
//  Created by Никита Гончаров on 07/10/2019.
//  Copyright © 2019 Никита Гончаров. All rights reserved.
//

import UIKit

class EmptyViewController: UIViewController {

    private var buttonSelector: ButtonSelectorView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let button1 = UIButton(frame: CGRect.zero)
        button1.backgroundColor = .clear
        if let image = UIImage(named: "plus_icon.png") { button1.setImage(image, for: .normal) }
        
        let button2 = UIButton(frame: CGRect.zero)
        button2.backgroundColor = .clear
        if let image = UIImage(named: "list_icon.png") { button2.setImage(image, for: .normal) }
        
        let button3 = UIButton(frame: CGRect.zero)
        button3.backgroundColor = .clear
        if let image = UIImage(named: "camera_icon.png") { button3.setImage(image, for: .normal) }
        
        let size = CGSize(width: view.bounds.width/5, height: view.bounds.height/5)
        let origin = CGPoint(x: view.bounds.midX - size.width/2, y: view.bounds.midY - size.height/2)
        let frameForView = CGRect(origin: origin, size: size)
        
        buttonSelector = ButtonSelectorView(frame: frameForView, button1: button1, button2: button2, button3: button3)
        buttonSelector.backgroundColor = #colorLiteral(red: 0.9405411869, green: 0.9405411869, blue: 0.9405411869, alpha: 1)
        buttonSelector.direction = .up
        view.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        
        view.addSubview(buttonSelector)
        
//        buttonSelector!.translatesAutoresizingMaskIntoConstraints = false
        self.view.addConstraint(NSLayoutConstraint(
            item: buttonSelector!,
            attribute: .bottom,
            relatedBy: .equal,
            toItem: view,
            attribute: .centerY,
            multiplier: 1,
            constant: 0))
        self.view.addConstraint(NSLayoutConstraint(
        item: buttonSelector!,
        attribute: .centerX,
        relatedBy: .equal,
        toItem: view,
        attribute: .centerX,
        multiplier: 1,
        constant: 0))
        
    }

}
