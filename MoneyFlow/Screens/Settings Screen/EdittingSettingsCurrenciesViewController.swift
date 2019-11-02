//
//  EdittingSettingsCurrenciesViewController.swift
//  MoneyFlow
//
//  Created by Никита Гончаров on 02/11/2019.
//  Copyright © 2019 Никита Гончаров. All rights reserved.
//

import UIKit

class EdittingSettingsCurrenciesViewController: UIViewController {
    
    let headerTableViewCellIdentifier = "headerCell"
    let settingEntityTableViewCellIdentifier = "settingEntityCell"
    private let tableViewRowHeight: CGFloat = 65
    private let headerCellTableViewRowHeight: CGFloat = 55
    private let currencyNameFont = UIFont(name: "CenturyGothic", size: 14.0)
    private let currencySignFont = UIFont(name: "HelveticaNeue-Light", size: 14.0)
    private let presenter = SettingsPresenter.shared
    
    @IBOutlet weak var tableView: UITableView!
    
    
    @IBAction func saveButtonTouched(_ sender: UIBarButtonItem) {
        
    }
    @IBAction func cancelButtonTouched(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func currencyName(for currency: Currency) -> String {
        switch currency {
        case .eur: return "Евро"
        case .rub: return "Рубль"
        case .usd: return "Доллар"
        }
    }
    

}

extension EdittingSettingsCurrenciesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.currencies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: settingEntityTableViewCellIdentifier, for: indexPath) as! SettingEntityTableViewCell
        let currencyNameString = NSAttributedString(
            string: currencyName(for: presenter.currencies[indexPath.row]) + ",  ",
            attributes: [NSAttributedString.Key.font: currencyNameFont])
        let currencySignString = NSAttributedString(
            string: presenter.currenciesSignes[indexPath.row],
            attributes: [NSAttributedString.Key.font: currencySignFont])
        let finalString = NSMutableAttributedString()
        finalString.append(currencyNameString)
        finalString.append(currencySignString)
        
        cell.titleLabel.attributedText = finalString
        cell.operationsCountLabel.text = "100"
        cell.enableSwitch.isOn = Bool.random()
        
        cell.enableSwitchValueDidChangeAction = { enable in
            print("Switcher #\(indexPath.row)'s state is \(enable)")
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
        header.periodLabel.text = "Валюты"
        header.sumLabel.isHidden = true
        
        return header.contentView
    }
    
    
}
