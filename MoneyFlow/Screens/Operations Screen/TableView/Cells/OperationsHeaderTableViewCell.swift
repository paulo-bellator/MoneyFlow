//
//  OperationsHeaderTableViewCell.swift
//  MoneyFlow
//
//  Created by Никита Гончаров on 05/09/2019.
//  Copyright © 2019 Никита Гончаров. All rights reserved.
//

import UIKit

class OperationsHeaderTableViewCell: UITableViewCell {
    
    @IBOutlet weak var periodLabel: UILabel! {
        didSet {
            periodLabel.isHidden = periodLabel.text == nil ? true : false
        }
    }
    @IBOutlet weak var sumLabel: UILabel! {
        didSet {
            sumLabel.isHidden = sumLabel.text == nil ? true : false
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }


}
