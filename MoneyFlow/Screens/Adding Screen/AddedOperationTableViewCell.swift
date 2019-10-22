//
//  AddedOperationsTableViewCell.swift
//  MoneyFlow
//
//  Created by Никита Гончаров on 22/10/2019.
//  Copyright © 2019 Никита Гончаров. All rights reserved.
//

import UIKit

class AddedOperationTableViewCell: OperationCleanDesignTableViewCell {

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var timeLabelSubstrateView: UIView!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let radius = CGSize(width: timeLabelSubstrateView.bounds.height/2, height: timeLabelSubstrateView.bounds.height/2)
        timeLabelSubstrateView.removeRoundedRectMask()
        timeLabelSubstrateView.addRoundedRectMask(corners: [.bottomRight], radius: radius)
    }

}

extension UIView {
    func addRoundedRectMask(corners: UIRectCorner, radius: CGSize) {
        let path = UIBezierPath(
            roundedRect: bounds,
            byRoundingCorners: corners,
            cornerRadii: radius)
        
        let shape = CAShapeLayer()
        shape.path = path.cgPath
        layer.mask = shape
    }
    func removeRoundedRectMask() { layer.mask = nil }
}
