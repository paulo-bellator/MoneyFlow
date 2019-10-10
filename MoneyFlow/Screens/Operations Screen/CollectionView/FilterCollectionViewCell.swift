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
                backgroundColor = .clear
                label?.textColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
                switch unit {
                case .all(let text):
                    label.text = text
                    label?.textColor = #colorLiteral(red: 0.2731202411, green: 0.2731202411, blue: 0.2731202411, alpha: 1)
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
                    case .all:
                        label?.textColor = #colorLiteral(red: 0.2731202411, green: 0.2731202411, blue: 0.2731202411, alpha: 1)
                    case .account:
                        label?.textColor = #colorLiteral(red: 0.9803921569, green: 0.831372549, blue: 0.4745098039, alpha: 1)
                    case .category:
                        label?.textColor = #colorLiteral(red: 0.9568627451, green: 0.6941176471, blue: 0.5137254902, alpha: 1)
                    case .currency:
                        label?.textColor = #colorLiteral(red: 0.7725490196, green: 0.8784313725, blue: 0.7058823529, alpha: 1)
                    case .contact:
                        label?.textColor = #colorLiteral(red: 0.4, green: 0.462745098, blue: 0.9490196078, alpha: 1)
                    }
                }
            } else {
                label?.textColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = self.bounds.height / 2.0
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
//        backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        backgroundColor = .clear
        isApplied = false
    }
}
