//
//  SettingsEditingTableViewManagingExtension.swift
//  MoneyFlow
//
//  Created by Никита Гончаров on 03/11/2019.
//  Copyright © 2019 Никита Гончаров. All rights reserved.
//

import UIKit

extension SettingsEditingViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingsEntites.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: settingEntityTableViewCellIdentifier, for: indexPath) as! SettingEntityTableViewCell
        
        let entityName = settingsEntites[indexPath.row].name
        cell.titleLabel.text = entityName
        cell.operationsCountLabel.text = "\(operationsCount[entityName] ?? 0)"
        cell.enableSwitch.isOn = settingsEntites[indexPath.row].enable
        
        cell.enableSwitchValueDidChangeAction = { [weak self] enable in
            self?.settingsEntites[indexPath.row].enable = enable
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
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard !settingsEntites.isEmpty else { return nil }
        if settingsType == .accounts && settingsEntites[indexPath.row].name == "Наличные" {
            return nil
        }
        let edit = UIContextualAction(style: .normal, title: "") { [weak self] (action, view, nil) in
            if self != nil {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let navVC = storyboard.instantiateViewController(withIdentifier: self!.renameVCStoryboardID) as! UINavigationController
                let editVC = navVC.viewControllers[0] as! SettingsEditingNameViewController
                editVC.delegate = self
                editVC.currentValue = self!.settingsEntites[indexPath.row].name
                editVC.settingsType = self!.settingsType
                self!.present(navVC, animated: true)
                
                tableView.setEditing(false, animated: true)
            }
        }
        edit.backgroundColor = #colorLiteral(red: 0.1490196078, green: 0.1490196078, blue: 0.1490196078, alpha: 1)
        edit.image = #imageLiteral(resourceName: "edit_icon")
        return UISwipeActionsConfiguration(actions: [edit])
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard settingsEntites.count > 1 else { return nil }
        if settingsType == .accounts && settingsEntites[indexPath.row].name == "Наличные" {
            return nil
        }
        let delete = UIContextualAction(style: .destructive, title: "") { [weak self] (action, view, nil) in
            if self != nil {
                let entityName = self!.settingsEntites[indexPath.row].name
                if self!.operationsCount[entityName]! > 0 {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let navVC = storyboard.instantiateViewController(withIdentifier: self!.deleteVCStoryboardID) as! UINavigationController
                    let deleteVC = navVC.viewControllers[0] as! SettingsDeletingViewController
                    deleteVC.delegate = self
                    deleteVC.deletingItemName = entityName
                    deleteVC.settingsType = self!.settingsType
                    self!.present(navVC, animated: true)
                    tableView.setEditing(false, animated: true)
                } else {
                    self!.deleteEntity(name: self!.settingsEntites[indexPath.row].name)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                }
            }
        }
        delete.backgroundColor = #colorLiteral(red: 0.1490196078, green: 0.1490196078, blue: 0.1490196078, alpha: 1)
        delete.image = #imageLiteral(resourceName: "delete_icon")
        return UISwipeActionsConfiguration(actions: [delete])
    }
}
