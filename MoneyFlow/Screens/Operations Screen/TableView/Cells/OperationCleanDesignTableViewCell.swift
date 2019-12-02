//
//  OperationCleanDesignTableViewCell.swift
//  MoneyFlow
//
//  Created by Никита Гончаров on 10/10/2019.
//  Copyright © 2019 Никита Гончаров. All rights reserved.
//

import UIKit

class OperationCleanDesignTableViewCell: UITableViewCell {
    
    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var accountLabel: UILabel!
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


