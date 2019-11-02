//
//  SettingsViewController.swift
//  MoneyFlow
//
//  Created by Никита Гончаров on 01/11/2019.
//  Copyright © 2019 Никита Гончаров. All rights reserved.
//

import UIKit
import FirebaseAuth

class SettingsViewController: UITableViewController, EditingSettingsViewControllerDelegate {
    
    @IBOutlet var securityEnablingSwitch: UISwitch!
    @IBOutlet var signOutButton: UIButton!
    
    private let edittingCurrenciesSegueIdentifier = "currenciesSegue"
    private let edittingSettingsSegueIdentifier = "settingsSegue"
    private let headerTableViewCellIdentifier = "headerCell"
    private let settingTableViewCellIdentifier = "settingCell"
    private let tableViewRowHeight: CGFloat = 65
    private let headerCellTableViewRowHeight: CGFloat = 55
    
    private let headerTitles = ["Настройки","Безопасность","Аккаунт"]
    private let settingsTitles = ["Валюты","Счета","Категории доходов","Категории расходов","Контакты"]
    private var settingValues = [String]()
    private let securityTitle = "Вход в приложение по Touch/Face ID"
    private var accountTitle: String = "Не авторизован"
    
    private let presenter = SettingsPresenter.shared
    var needToUpdate: Bool = false

    @IBAction func signOutButtonTouched(_ sender: UIButton) {
        showSignOutActionSheet()
    }
    @IBAction func securityEnablingSwitchDidChange(_ sender: UISwitch) {
        print("Switch's changed to \(sender.isOn)")
        UserDefaults().set(sender.isOn, forKey: GlobalConstants.securityEnablingDefaultsKey)
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        let securityEnabled = UserDefaults().bool(forKey: GlobalConstants.securityEnablingDefaultsKey)
        securityEnablingSwitch.setOn(securityEnabled, animated: false)
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
    }
    
    private func showSignOutActionSheet() {
        let actionSheet = UIAlertController(title: "Вы уверены что хотите выйти?", message: " Из аккаунта \(accountTitle)", preferredStyle: .actionSheet)
        let signOutAction = UIAlertAction(title: "Выйти", style: .destructive) { _ in
            try? Auth.auth().signOut()
            print("SIGN OUT")
        }
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
        actionSheet.addAction(signOutAction)
        actionSheet.addAction(cancelAction)
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    @objc func currencyEditingTapGestureRecognized(_ recognizer: UITapGestureRecognizer) {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        performSegue(withIdentifier: edittingCurrenciesSegueIdentifier, sender: nil)
    }
    
    func dataChanged() {
        loadData()
        tableView.reloadData()
        sendUpdateRequirementToVCs()
        print("dataChanged")
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
            if let vc = navVC.viewControllers[0] as? EditingSettingsCurrenciesViewController {
                vc.delegate = self
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
            if indexPath.row == 0 {
                let tapGestureRecognizer = UITapGestureRecognizer()
                tapGestureRecognizer.addTarget(self, action: #selector(currencyEditingTapGestureRecognized(_:)))
                cell.addGestureRecognizer(tapGestureRecognizer)
            }
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
