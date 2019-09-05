//
//  FilterCollectionViewCell.swift
//  MoneyFlow
//
//  Created by Никита Гончаров on 05/09/2019.
//  Copyright © 2019 Никита Гончаров. All rights reserved.
//

import UIKit

class FilterCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var label: UILabel!
    var isApplied: Bool = false {
        didSet {
            if isApplied {
                label?.textColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
                layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
                layer.borderWidth = 0
//                label.text = "× " + (label.text ?? "")
            } else {
                label?.textColor = #colorLiteral(red: 0.7829024099, green: 0.7829024099, blue: 0.7829024099, alpha: 1)
                layer.borderColor = #colorLiteral(red: 0.9646214843, green: 0.9647598863, blue: 0.9645912051, alpha: 1)
                layer.borderWidth = 0
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        label?.textColor = #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)
        backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        layer.borderColor = #colorLiteral(red: 0.9646214843, green: 0.9647598863, blue: 0.9645912051, alpha: 1)
        layer.borderWidth = 0
        layer.cornerRadius = 15
    }
}
