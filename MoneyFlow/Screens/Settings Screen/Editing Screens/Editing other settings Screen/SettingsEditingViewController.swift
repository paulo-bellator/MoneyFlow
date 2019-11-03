//
//  SettingsEditingViewController.swift
//  MoneyFlow
//
//  Created by Никита Гончаров on 03/11/2019.
//  Copyright © 2019 Никита Гончаров. All rights reserved.
//

import UIKit

class SettingsEditingViewController: UIViewController {
    
    let headerTableViewCellIdentifier = "headerCell"
    let settingEntityTableViewCellIdentifier = "settingEntityCell"
    let tableViewRowHeight: CGFloat = 65
    let headerCellTableViewRowHeight: CGFloat = 55
    let currencyNameFont = UIFont(name: "CenturyGothic", size: 14.0)!
    let currencySignFont = UIFont(name: "HelveticaNeue-Light", size: 14.0)!
    var settingsType: SettingsEntityType = .accounts
    var settingsEntites = [SettingsEntity]()
    private(set) var operationsCount = [String: Int]()
    private lazy var defaultPresenter = SettingEditingPresenter()
    weak var presenter: SettingEditingPresenter!
    weak var delegate: SettingsEditingViewControllerDelegate?
    
    private var presenterSettingEntites: [SettingsEntity] {
        get {
            switch settingsType {
            case .accounts: return presenter.accounts
            case .incomeCategories: return presenter.incomeCategories
            case .outcomeCategories: return presenter.outcomeCategories
            case .contacts: return presenter.contacts
            default: return presenter.accounts
            }
        } set {
            switch settingsType {
            case .accounts: presenter.accounts = newValue
            case .incomeCategories: presenter.incomeCategories = newValue
            case .outcomeCategories: presenter.outcomeCategories = newValue
            case .contacts: presenter.contacts = newValue
            default: break
            }
        }
    }
    

    @IBOutlet weak var tableView: UITableView!
    
    

    @IBAction func cancelButtonTouched(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
    }
    
    @IBAction func saveButtonTouched(_ sender: UIBarButtonItem) {
        if settingsEntites.compactMap({ $0.enable ? $0 : nil }).isEmpty {
            showErrorAlertSheet()
        } else {
            if presenterSettingEntites != settingsEntites {
                presenterSettingEntites = settingsEntites
                presenter.syncronize()
                delegate?.dataChanged()
            }
            self.dismiss(animated: true)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        if presenter == nil {
            presenter = defaultPresenter
        }
        
        settingsEntites = presenterSettingEntites
        switch settingsType {
        case .accounts: operationsCount = presenter.operationsCountWithAccounts
        case .incomeCategories: operationsCount = presenter.operationsCountWithIncomeCategories
        case .outcomeCategories: operationsCount = presenter.operationsCountWithOutcomeCategories
        case .contacts: operationsCount = presenter.operationsCountWithContacts
        default: break
        }
    }
    
    private func showErrorAlertSheet() {
        var message = "Как минимум одна \(settingsType.singularString.lowercased()) должна быть активна."
        
        switch settingsType {
        case .accounts: message = "Как минимум один счет должен быть активен."
        case .incomeCategories: message = "Как минимум одна категория должна быть активна."
        case .outcomeCategories: message = "Как минимум одна категория должна быть активна."
        case .contacts: message = "Как минимум один контакт должен быть активен."
        default: break
        }
        
        let ac = UIAlertController(title: "Так не пойдет... ", message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Oк", style: .default))
        present(ac, animated: true)
    }
    
}