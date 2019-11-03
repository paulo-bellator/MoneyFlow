//
//  SettingsEditingCurrenciesManagingTableViewExtension.swift
//  MoneyFlow
//
//  Created by Никита Гончаров on 03/11/2019.
//  Copyright © 2019 Никита Гончаров. All rights reserved.
//

import UIKit

extension SettingsEditingCurrenciesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.currencies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: settingEntityTableViewCellIdentifier, for: indexPath) as! SettingEntityTableViewCell
        let currency = currencies[indexPath.row].currency
        let currencyNameString = NSAttributedString(
            string: currencyName(for: currency) + ",  ",
            attributes: [NSAttributedString.Key.font: currencyNameFont])
        let currencySignString = NSAttributedString(
            string: currency.rawValue,
            attributes: [NSAttributedString.Key.font: currencySignFont])
        let finalString = NSMutableAttributedString()
        finalString.append(currencyNameString)
        finalString.append(currencySignString)
        
        cell.titleLabel.attributedText = finalString
        cell.operationsCountLabel.text = "\(presenter.operationsCountWithCurrencies[currency] ?? 0)"
        cell.enableSwitch.isOn = currencies[indexPath.row].enable
        
        cell.enableSwitchValueDidChangeAction = { [weak self] enable in
            self?.currencies[indexPath.row].enable = enable
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return headerCellTableViewRowHeight
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableViewRowHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableCell(withIdentifier: headerTableViewCellIdentifier) as! OperationsHeaderTableViewCell
        header.periodLabel.text = settingsType.pluralString
        header.sumLabel.isHidden = true
        
        return header.contentView
    }
}
