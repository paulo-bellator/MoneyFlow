//
//  SummaryTableViewCell.swift
//  MoneyFlow
//
//  Created by Никита Гончаров on 18/09/2019.
//  Copyright © 2019 Никита Гончаров. All rights reserved.
//

import UIKit

class SummaryTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet var valueLabels: [UILabel]!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
