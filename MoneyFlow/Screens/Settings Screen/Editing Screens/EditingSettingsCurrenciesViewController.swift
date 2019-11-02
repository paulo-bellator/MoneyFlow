//
//  EdittingSettingsCurrenciesViewController.swift
//  MoneyFlow
//
//  Created by Никита Гончаров on 02/11/2019.
//  Copyright © 2019 Никита Гончаров. All rights reserved.
//

import UIKit

protocol EditingSettingsViewControllerDelegate: class {
    func dataChanged()
}

class EditingSettingsCurrenciesViewController: UIViewController {
    
    let headerTableViewCellIdentifier = "headerCell"
    let settingEntityTableViewCellIdentifier = "settingEntityCell"
    private let tableViewRowHeight: CGFloat = 65
    private let headerCellTableViewRowHeight: CGFloat = 55
    private let currencyNameFont = UIFont(name: "CenturyGothic", size: 14.0)!
    private let currencySignFont = UIFont(name: "HelveticaNeue-Light", size: 14.0)!
    private lazy var presenter = SettingEditingPresenter()
    private lazy var currencies = presenter.currencies
    weak var delegate: EditingSettingsViewControllerDelegate?
    
    @IBOutlet weak var tableView: UITableView!
    
    
    @IBAction func saveButtonTouched(_ sender: UIBarButtonItem) {
        if currencies.compactMap({ $0.enable ? $0 : nil }).isEmpty {
            showErrorAlertSheet()
        } else {
            delegate?.dataChanged()
            presenter.currencies = currencies
            presenter.syncronize()
            self.dismiss(animated: true)
        }
    }
    
    @IBAction func cancelButtonTouched(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func showErrorAlertSheet() {
        let message = "Как минимум одна валюта должна быть активна."
        let ac = UIAlertController(title: "Так не пойдет... ", message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Oк", style: .default))
        present(ac, animated: true)
    }
    
    private func currencyName(for currency: Currency) -> String {
        switch currency {
        case .eur: return "Евро"
        case .rub: return "Рубль"
        case .usd: return "Доллар"
        }
    }
}

extension EditingSettingsCurrenciesViewController: UITableViewDelegate, UITableViewDataSource {
    
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
        header.periodLabel.text = "Валюты"
        header.sumLabel.isHidden = true
        
        return header.contentView
    }
}
