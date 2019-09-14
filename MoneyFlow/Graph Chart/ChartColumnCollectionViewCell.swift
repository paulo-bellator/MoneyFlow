//
//  ChartColumnCollectionViewCell.swift
//  MoneyFlow
//
//  Created by Никита Гончаров on 13/09/2019.
//  Copyright © 2019 Никита Гончаров. All rights reserved.
//

import UIKit

class ChartColumnCollectionViewCell: UICollectionViewCell {
    
    var wasSeen = false
    
    @IBOutlet weak var chartColumnView: ChartColumnView!
    @IBOutlet weak var label: UILabel!
    
    override func prepareForReuse() {
        wasSeen = true
    }
    
}
