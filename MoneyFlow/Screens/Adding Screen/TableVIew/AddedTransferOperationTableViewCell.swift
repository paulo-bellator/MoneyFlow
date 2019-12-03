//
//  AddedTransferOperationTableViewCell.swift
//  MoneyFlow
//
//  Created by Никита Гончаров on 03/12/2019.
//  Copyright © 2019 Никита Гончаров. All rights reserved.
//

import UIKit

class AddedTransferOperationTableViewCell: OperationTransferTableViewCell {

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var timeLabelSubstrateView: UIView!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let radius = CGSize(width: timeLabelSubstrateView.bounds.height/2, height: timeLabelSubstrateView.bounds.height/2)
        timeLabelSubstrateView.removeRoundedRectMask()
        timeLabelSubstrateView.addRoundedRectMask(corners: [.bottomRight], radius: radius)
    }

}
