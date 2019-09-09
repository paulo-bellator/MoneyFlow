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
    var filterUnit: FilterUnit! {
        didSet {
            if let unit = filterUnit {
                switch unit {
                case .all(let text): label.text = text
                case .account(let text): label.text = text
                case .category(let text): label.text = text
                case .currency(let text): label.text = text
                case .contact(let text): label.text = text
                }
            }
        }
    }
    
    var isApplied: Bool = false {
        didSet {
            if isApplied {
                if let unit = filterUnit {
                    switch unit {
                    case .all: label?.textColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
                    case .account: label?.textColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
                    case .category: label?.textColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
                    case .currency: label?.textColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
                    case .contact: label?.textColor = #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)
                    }
                }
//                label?.textColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
                layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
                layer.borderWidth = 0
            } else {
                label?.textColor = #colorLiteral(red: 0.7829024099, green: 0.7829024099, blue: 0.7829024099, alpha: 1)
                layer.borderColor = #colorLiteral(red: 0.9646214843, green: 0.9647598863, blue: 0.9645912051, alpha: 1)
                layer.borderWidth = 0
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        layer.cornerRadius = 15
        isApplied = false
    }
}
