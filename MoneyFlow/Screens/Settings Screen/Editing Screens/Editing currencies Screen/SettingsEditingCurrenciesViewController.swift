//
//  EdittingSettingsCurrenciesViewController.swift
//  MoneyFlow
//
//  Created by Никита Гончаров on 02/11/2019.
//  Copyright © 2019 Никита Гончаров. All rights reserved.
//

import UIKit

protocol SettingsEditingViewControllerDelegate: class {
    func dataChanged()
}

class SettingsEditingCurrenciesViewController: UIViewController {
    
    let headerTableViewCellIdentifier = "headerCell"
    let settingEntityTableViewCellIdentifier = "settingEntityCell"
    let tableViewRowHeight: CGFloat = 65
    let headerCellTableViewRowHeight: CGFloat = 55
    let currencyNameFont = UIFont(name: "CenturyGothic", size: 14.0)!
    let currencySignFont = UIFont(name: "HelveticaNeue-Light", size: 14.0)!
    let settingsType: SettingsEntityType = .currencies
    lazy var currencies = presenter.currencies
    private lazy var defaultPresenter = SettingEditingPresenter()
    weak var presenter: SettingEditingPresenter!
    weak var delegate: SettingsEditingViewControllerDelegate?
    
    
    @IBOutlet weak var tableView: UITableView!
    
    
    @IBAction func saveButtonTouched(_ sender: UIBarButtonItem) {
        if currencies.compactMap({ $0.enable ? $0 : nil }).isEmpty {
            showErrorAlertSheet()
        } else {
            if presenter.currencies != currencies {
                presenter.currencies = currencies
                presenter.syncronize()
                delegate?.dataChanged()
            }
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
        
        if presenter == nil {
            presenter = defaultPresenter
        }
    }
    
    private func showErrorAlertSheet() {
        let message = "Как минимум одна \(settingsType.singularString.lowercased()) должна быть активна."
        let ac = UIAlertController(title: "Так не пойдет... ", message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Oк", style: .default))
        present(ac, animated: true)
    }
    
    func currencyName(for currency: Currency) -> String {
        switch currency {
        case .eur: return "Евро"
        case .rub: return "Рубль"
        case .usd: return "Доллар"
        }
    }
}

