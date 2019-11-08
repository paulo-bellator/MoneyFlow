//
//  SettingsEditingViewController.swift
//  MoneyFlow
//
//  Created by Никита Гончаров on 03/11/2019.
//  Copyright © 2019 Никита Гончаров. All rights reserved.
//

import UIKit

class SettingsEditingViewController: UIViewController, SettingsEditingNameViewControllerDelegate, SettingsDeletingViewControllerDelegate, AddSettingsEntityViewControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var buttonSubstrateView: UIView!
    let renameVCStoryboardID = "editNameNavVC"
    let deleteVCStoryboardID = "deleteNavVC"
    let addVCStoryboardID = "addNavVC"
    let nameEditingSegueIdentifier = "nameEditingSegue"
    let headerTableViewCellIdentifier = "headerCell"
    let settingEntityTableViewCellIdentifier = "settingEntityCell"
    let tableViewRowHeight: CGFloat = 65
    let headerCellTableViewRowHeight: CGFloat = 55
    let currencyNameFont = UIFont(name: "CenturyGothic", size: 14.0)!
    let currencySignFont = UIFont(name: "HelveticaNeue-Light", size: 14.0)!
    var settingsType: SettingsEntityType = .accounts
    var settingsEntites = [SettingsEntity]()
    private(set) var operationsCount = [String: Int]()
    private let presenter = SettingEditingPresenter.shared
    weak var delegate: SettingsEditingViewControllerDelegate?
    fileprivate let loadManager = DataSourceLoadManager.shared
    fileprivate var loadingView: LoadingView?
    
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
    
    @IBAction func addButtonTouched(_ sender: UIButton) {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let navVC = storyboard.instantiateViewController(withIdentifier: addVCStoryboardID) as! UINavigationController
        let addVC = navVC.viewControllers[0] as! AddSettingsEntityViewController
        addVC.delegate = self
        addVC.settingsType = settingsType
        present(navVC, animated: true)
    }
    
    @IBAction func cancelButtonTouched(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let radius: CGFloat = buttonSubstrateView.bounds.width / 2.0
        buttonSubstrateView.layer.cornerRadius = radius
        buttonSubstrateView.addRoundedShadow(corners: .allCorners, radius: CGSize(width: radius, height: radius))
        
        loadManager.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        
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
    
    func settingEntityRenamed(type: SettingsEntityType, oldValue: String, newValue: String) {
        operationsCount[newValue] = operationsCount[oldValue]
        operationsCount[oldValue] = nil

        var originSettingsEntites = presenterSettingEntites
        for (index, var settingsEntity) in originSettingsEntites.enumerated() {
            if settingsEntity.name == oldValue {
                settingsEntity.name = newValue
                originSettingsEntites[index] = settingsEntity
                break
            }
        }
        presenterSettingEntites = originSettingsEntites
        settingsEntites = presenterSettingEntites
        tableView.reloadData()
        replaceEntityInOperations(type: settingsType, oldValue: oldValue, newValue: newValue, syncronize: true)
        loadManager.newSession()
        presenter.syncronize()
        delegate?.dataChanged()
    }
    
    func settingEntityDeleted(type: SettingsEntityType, deletedItem: String, moveIntoItem: String) {
        operationsCount[moveIntoItem]! += operationsCount[deletedItem]!
        operationsCount[deletedItem] = nil
        presenterSettingEntites = presenterSettingEntites.compactMap { $0.name == deletedItem ? nil : $0 }
        settingsEntites = presenterSettingEntites
        if settingsEntites.compactMap({ $0.enable ? $0 : nil }).isEmpty {
            settingsEntites[0].enable = true
            presenterSettingEntites = settingsEntites
        }
        tableView.reloadData()
        replaceEntityInOperations(type: settingsType, oldValue: deletedItem, newValue: moveIntoItem, syncronize: true)
        loadManager.newSession()
        presenter.syncronize()
        delegate?.dataChanged()
    }
    
    func deleteEntity(name: String) {
        operationsCount[name] = nil
        presenterSettingEntites = presenterSettingEntites.compactMap { $0.name == name ? nil : $0 }
        settingsEntites = presenterSettingEntites
        if settingsEntites.compactMap({ $0.enable ? $0 : nil }).isEmpty {
            let cell = tableView.visibleCells[0]
            let index = tableView.indexPath(for: cell)!.row
            (cell as! SettingEntityTableViewCell).enableSwitch.setOn(true, animated: true)
            settingsEntites[index].enable = true
            presenterSettingEntites = settingsEntites
        }
        loadManager.newSession()
        presenter.syncronize()
        delegate?.dataChanged()
    }
    
    func settingsEntityAdded(type: SettingsEntityType, name: String) {
        operationsCount[name] = 0
        let entity = SettingsEntity(name: name)
        presenterSettingEntites = presenterSettingEntites + [entity]
        settingsEntites = presenterSettingEntites
        tableView.reloadData()
        loadManager.newSession()
        presenter.syncronize()
        delegate?.dataChanged()
    }
    
    private func replaceEntityInOperations(type: SettingsEntityType, oldValue: String, newValue: String, syncronize: Bool = false) {
        switch type {
        case .accounts: presenter.replaceAccountInOperations(currentAccount: oldValue, newAccount: newValue, syncronize: syncronize)
        case .incomeCategories: presenter.replaceIncomeCategoryInOperations(currentCategory: oldValue, newCategory: newValue, syncronize: syncronize)
        case .outcomeCategories: presenter.replaceOutcomeCategoryInOperations(currentCategory: oldValue, newCategory: newValue, syncronize: syncronize)
        case .contacts: presenter.replaceContactInOperations(currentContact: oldValue, newContact: newValue, syncronize: syncronize)
        default: break
        }
    }
    
}

extension SettingsEditingViewController: DataSourceLoadManagerDelegate {
    var uploadProgress: Double {
        get { return 0 }
        set {
            if loadingView == nil { showLoadingView(withProcessName: "Сохранение", animated: true) }
        }
    }
    func uploadComplete(with error: Error?) {
        removeLoadingView()
    }
    private func showLoadingView(withProcessName name: String, animated: Bool = true) {
        loadingView = LoadingView(superview: self.view)
        tabBarController?.tabBar.isHidden = true
        navigationController?.navigationBar.isHidden = true
        loadingView!.mainLabel.text = name
        loadingView!.breakButton.setTitle("Прервать", for: .normal)
        loadingView!.breakAction = { [weak self] in
            self?.loadManager.cancelLoading()
            self?.removeLoadingView()
        }
        loadingView!.appear(animated: animated)
    }
    private func removeLoadingView(animated: Bool = true) {
        tabBarController?.tabBar.isHidden = false
        navigationController?.navigationBar.isHidden = false
        loadingView?.remove(animated: animated, duration: 0.4)
        loadingView = nil
    }
}
