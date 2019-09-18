//
//  SummaryHeaderTableViewCell.swift
//  MoneyFlow
//
//  Created by Никита Гончаров on 18/09/2019.
//  Copyright © 2019 Никита Гончаров. All rights reserved.
//

import UIKit

@IBDesignable
class SummaryHeaderTableViewCell: UITableViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        addRoundedRectsMask()
    }
    
    private func addRoundedRectsMask() {
        let topRect = CGRect(x: bounds.minX, y: bounds.minY - 15.0, width: bounds.width, height: 35.0)
        let pathTopRect = UIBezierPath(roundedRect: topRect,
                                byRoundingCorners: [.bottomLeft, .bottomRight],
                                cornerRadii: CGSize(width: 20.0, height: 35.0))
        let bottomRect = CGRect(x: bounds.minX, y: bounds.maxY - 15.0, width: bounds.width, height: 35.0)
        let pathBottomRect = UIBezierPath(roundedRect: bottomRect,
                                          byRoundingCorners: [.topLeft, .topRight],
                                          cornerRadii: CGSize(width: 20.0, height: 35.0))
        let path = UIBezierPath()
        path.append(pathTopRect)
        path.append(pathBottomRect)
        
        let shape = CAShapeLayer()
        shape.path = path.cgPath
        shape.fillColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
//        shape.masksToBounds = true
//        layer.mask = shape
        layer.insertSublayer(shape, at: 0)
    }
}
