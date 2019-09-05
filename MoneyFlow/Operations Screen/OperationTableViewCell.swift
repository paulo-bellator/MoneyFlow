//
//  OperationTableViewCell.swift
//  MoneyFlow
//
//  Created by Никита Гончаров on 04/09/2019.
//  Copyright © 2019 Никита Гончаров. All rights reserved.
//

import UIKit

class OperationTableViewCell: UITableViewCell {

    
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var emojiLabel: UILabel!
    @IBOutlet weak var accountLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel! {
        didSet {
            commentLabel.isHidden = commentLabel.text == nil ? true : false
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
