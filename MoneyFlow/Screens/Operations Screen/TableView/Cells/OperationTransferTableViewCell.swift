//
//  OperationTransferTableViewCell.swift
//  MoneyFlow
//
//  Created by Никита Гончаров on 02/12/2019.
//  Copyright © 2019 Никита Гончаров. All rights reserved.
//

import UIKit

class OperationTransferTableViewCell: UITableViewCell {

    @IBOutlet weak var fromAccountLabel: UILabel!
    @IBOutlet weak var toAccountLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var typeIndicatorView: UIView!
    
    var typeIndicatorColor: UIColor = UIColor.red {
        didSet {
            typeIndicatorView.backgroundColor = typeIndicatorColor
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        typeIndicatorView?.layer.cornerRadius = (typeIndicatorView?.bounds.width ?? 0)/2
    }
}
