//
//  CircleGraphView.swift
//  MoneyFlow
//
//  Created by Никита Гончаров on 18/09/2019.
//  Copyright © 2019 Никита Гончаров. All rights reserved.
//

import UIKit

class CircleGraphView: UIView {
    
    var zeroCrossRadiusScale: CGFloat = 0.15
    
    @IBInspectable
    var value: CGFloat = 1.0 {
        didSet {
            value = min(max(value, 0.0), 1.0)
            setNeedsDisplay()
        }
    }
    var minRadiusScale: CGFloat = 0.1
    
    override func draw(_ rect: CGRect) {
        // Drawing code
        if value != 0.0 {
            let radius = min(bounds.height, bounds.width) * max(value, minRadiusScale)
            let origin = CGPoint(x: bounds.midX - radius/2, y: bounds.midY - radius/2)
            let size = CGSize(width: radius, height: radius)
            
            let path = UIBezierPath(ovalIn: CGRect(origin: origin, size: size))
            let mask = CAShapeLayer()
            mask.path = path.cgPath
            layer.mask = mask
        } else {
            let radius = min(bounds.height, bounds.width) * zeroCrossRadiusScale
            let path = UIBezierPath()
            path.move(to: CGPoint(x: bounds.midX - radius/2 , y: bounds.midY - radius/2))
            path.addLine(to: CGPoint(x: bounds.midX + radius/2 , y: bounds.midY + radius/2))
            path.move(to: CGPoint(x: bounds.midX + radius/2, y: bounds.midY - radius/2))
            path.addLine(to: CGPoint(x: bounds.midX - radius/2, y: bounds.midY + radius/2))

            let mask = CAShapeLayer()
            mask.fillColor = nil
            mask.strokeColor = UIColor.black.cgColor
            mask.path = path.cgPath
            mask.lineWidth = 1.5
            layer.mask = mask
        }
    }
    
}
