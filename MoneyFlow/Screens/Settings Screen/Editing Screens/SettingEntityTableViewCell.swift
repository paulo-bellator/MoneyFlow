//
//  SettingEntityTableViewCell.swift
//  MoneyFlow
//
//  Created by Никита Гончаров on 02/11/2019.
//  Copyright © 2019 Никита Гончаров. All rights reserved.
//

import UIKit

class SettingEntityTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var operationsCountLabel: UILabel!
    @IBOutlet weak var enableSwitch: UISwitch!
    
    /// This closure will be called, when enableSwitch changes its state
    var enableSwitchValueDidChangeAction: ((_ enable: Bool) -> Void)?
    
    @IBAction func switchValueDidChange(_ sender: UISwitch) {
        enableSwitchValueDidChangeAction?(sender.isOn)
    }
}
