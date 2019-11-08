//
//  SettingsViewController.swift
//  MoneyFlow
//
//  Created by Никита Гончаров on 01/11/2019.
//  Copyright © 2019 Никита Гончаров. All rights reserved.
//

import UIKit
import FirebaseAuth

class SettingsViewController: UITableViewController, SettingsEditingViewControllerDelegate, UpdatableViewController {
    
    @IBOutlet var securityEnablingSwitch: UISwitch!
    @IBOutlet var signOutButton: UIButton!
    
    private let editingCurrenciesSegueIdentifier = "currenciesSegue"
    private let editingSettingsSegueIdentifier = "settingsSegue"
    private let headerTableViewCellIdentifier = "headerCell"
    private let settingTableViewCellIdentifier = "settingCell"
    private let tableViewRowHeight: CGFloat = 65
    private let headerCellTableViewRowHeight: CGFloat = 55
    
    private let headerTitles = ["Настройки","Безопасность","Аккаунт"]
    private let settingsTitles = SettingsEntityType.allPluralStrings
    private var settingValues = [String]()
    private let securityTitle = "Вход в приложение по Touch/Face ID"
    private var accountTitle: String = "Не авторизован"
    
    private let presenter = SettingsPresenter.shared
    var needToUpdate: Bool = false
    var loadingView: LoadingView?
    lazy var loadManager = DataSourceLoadManager.shared

    @IBAction func signOutButtonTouched(_ sender: UIButton) {
        showSignOutActionSheet()
    }
    @IBAction func securityEnablingSwitchDidChange(_ sender: UISwitch) {
        print("Switch's changed to \(sender.isOn)")
        UserDefaults().set(sender.isOn, forKey: GlobalConstants.DefaultsKeys.securityEnabling)
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        let securityEnabled = UserDefaults().bool(forKey: GlobalConstants.DefaultsKeys.securityEnabling)
        securityEnablingSwitch.setOn(securityEnabled, animated: false)
        SettingEditingPresenter.shared.configure()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if needToUpdate {
            loadData()
            tableView.reloadData()
            needToUpdate = false
        }
    }
    
    private func loadData() {
        var array = [String]()
        array.append("\(presenter.currencies.count)")
        array.append("\(presenter.accounts.count)")
        array.append("\(presenter.incomeCategories.count)")
        array.append("\(presenter.outcomeCategories.count)")
        array.append("\(presenter.contacts.count)")
        settingValues = array
        accountTitle = Auth.auth().currentUser?.email ?? "Не авторизован"
        DispatchQueue.global(qos: .userInitiated).async {
            SettingEditingPresenter.shared.updateData()
        }
    }
    
    private func showSignOutActionSheet() {
        let actionSheet = UIAlertController(title: "Вы уверены что хотите выйти?", message: " Из аккаунта \(accountTitle)", preferredStyle: .actionSheet)
        let signOutAction = UIAlertAction(title: "Выйти", style: .destructive) { [weak self] _ in
            self?.saveDataAndSignOut()
        }
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
        actionSheet.addAction(signOutAction)
        actionSheet.addAction(cancelAction)
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    private func saveDataAndSignOut() {
        if loadManager.isCloudDataSource {
            showLoadingView(withProcessName: "Сохранение")
            loadManager.delegate = self
            loadManager.newSession()
            (MainData.source as? CloudOperationDataSource)?.saveToStorageForced()
            (MainData.settings as? CloudSettingsDataSource)?.save()
        } else {
            try? Auth.auth().signOut()
            print("SIGN OUT")
        }
    }
    
    @objc func settingsEditingTapGestureRecognized(_ recognizer: UITapGestureRecognizer) {
        if let recognizerName = recognizer.name {
            if let settingsType = SettingsEntityType.settingsEntityTypeFrom(pluralString: recognizerName) {
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
                if settingsType == .currencies {
                    performSegue(withIdentifier: editingCurrenciesSegueIdentifier, sender: nil)
                } else {
                    performSegue(withIdentifier: editingSettingsSegueIdentifier, sender: settingsType)
                }
            }
        }
    }
    
    func dataChanged() {
        loadData()
        tableView.reloadData()
        sendUpdateRequirementToVCs()
    }
    
    private func sendUpdateRequirementToVCs() {
        if let tabVC = tabBarController {
            for vc in tabVC.viewControllers ?? [] {
                if var updatableVC = vc as? UpdatableViewController {
                    updatableVC.needToUpdate = true
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let navVC = segue.destination as? UINavigationController {
            if let vc = navVC.viewControllers[0] as? SettingsEditingCurrenciesViewController {
                vc.delegate = self
            } else if let vc = navVC.viewControllers[0] as? SettingsEditingViewController {
                vc.delegate = self
                if let settingsType = sender as? SettingsEntityType {
                    vc.settingsType = settingsType
                }
            }
        }
    }
    

    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 5
        case 1: return 1
        case 2: return 1
        default: return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return headerCellTableViewRowHeight 
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableViewRowHeight
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: settingTableViewCellIdentifier, for: indexPath) as! TwoLabledTableViewCell
        
        switch indexPath.section {
        case 0:
            cell.leftLabel.text = settingsTitles[indexPath.row]
            cell.rightLabel.text = settingValues[indexPath.row]
            
            let tapGestureRecognizer = UITapGestureRecognizer()
            tapGestureRecognizer.addTarget(self, action: #selector(settingsEditingTapGestureRecognized(_:)))
            tapGestureRecognizer.name = settingsTitles[indexPath.row]
            cell.addGestureRecognizer(tapGestureRecognizer)
        case 1:
            cell.leftLabel.text = securityTitle
            cell.rightLabel?.removeFromSuperview()
            cell.accessoryView = securityEnablingSwitch
            let constraint = NSLayoutConstraint(
                item: cell.leftLabel!, attribute: .trailing, relatedBy: .equal,
                toItem: cell, attribute: .trailing, multiplier: 1.0, constant: -30 - cell.accessoryView!.bounds.width)
            cell.addConstraint(constraint)
        case 2:
            cell.leftLabel.text = accountTitle
            cell.rightLabel.isHidden = true
            cell.accessoryView = signOutButton
        default: break
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableCell(withIdentifier: headerTableViewCellIdentifier) as! OperationsHeaderTableViewCell
        header.periodLabel.text = headerTitles[section]
        header.sumLabel.isHidden = true
        
        return header.contentView
    }

}

enum SettingsEntityType {
    case currencies, accounts, incomeCategories, outcomeCategories, contacts
    
    var pluralString: String {
        switch self {
        case .currencies: return "Валюты"
        case .accounts: return "Счета"
        case .incomeCategories: return "Категории доходов"
        case .outcomeCategories: return "Категории расходов"
        case .contacts: return "Контакты"
        }
    }
    
    var singularString: String {
        switch self {
        case .currencies: return "Валюта"
        case .accounts: return "Счет"
        case .incomeCategories: return "Категория доходов"
        case .outcomeCategories: return "Категория расходов"
        case .contacts: return "Контакт"
        }
    }
    
    static let allPluralStrings = ["Валюты","Счета","Категории доходов","Категории расходов","Контакты"]
    
    static func settingsEntityTypeFrom(pluralString string: String) -> SettingsEntityType? {
        switch string {
        case "Валюты": return .currencies
        case "Счета": return .accounts
        case "Категории доходов": return .incomeCategories
        case "Категории расходов": return .outcomeCategories
        case "Контакты": return .contacts
        default: return nil
        }
    }
}

extension SettingsViewController: DataSourceLoadManagerDelegate {
    func uploadComplete(with error: Error?) {
        removeLoadingView()
        if error == nil {
            try? Auth.auth().signOut()
            print("SIGN OUT")
        }
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
            self?.showErrorSaveDataAlertSheet()
        }
        loadingView!.appear(animated: animated)
    }
    private func removeLoadingView(animated: Bool = true) {
        tabBarController?.tabBar.isHidden = false
        navigationController?.navigationBar.isHidden = false
        loadingView?.remove(animated: animated, duration: 0.4)
        loadingView = nil
    }
    
    private func showErrorSaveDataAlertSheet() {
        var message = "Данные могли быть не сохранены."
        let ac = UIAlertController(title: "Ошибка сохранения.", message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Остаться", style: .cancel))
        let logOutAction = UIAlertAction(title: "Выйти", style: .destructive) { _ in
            try? Auth.auth().signOut()
            print("SIGN OUT")
        }
        ac.addAction(logOutAction)
        present(ac, animated: true)
    }
}
