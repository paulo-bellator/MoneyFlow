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
                let navVC = storyboard.instantiateViewController(withIdentifier: "editNameNavVC") as! UINavigationController
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
        guard !settingsEntites.isEmpty else { return nil }
        if settingsType == .accounts && settingsEntites[indexPath.row].name == "Наличные" {
            return nil
        }
        let delete = UIContextualAction(style: .destructive, title: "") { [unowned self] (action, view, nil) in
//            let idOfOperationsToRemove = self.operationsByDays[indexPath.section].ops.remove(at: indexPath.row).id
//            self.presenter.removeOperationWith(identifier: idOfOperationsToRemove)
//            self.presenter.syncronize()
            
//            if self.operationsByDays[indexPath.section].ops.isEmpty {
//                self.operationsByDays.remove(at: indexPath.section)
//                tableView.deleteSections(IndexSet(integer: indexPath.section), with: .fade)
//            } else {
//                tableView.deleteRows(at: [indexPath], with: .fade)
//            }
//            self.sendUpdateRequirementToVCs()
        }
        delete.backgroundColor = #colorLiteral(red: 0.1490196078, green: 0.1490196078, blue: 0.1490196078, alpha: 1)
        delete.image = #imageLiteral(resourceName: "delete_icon")
        return UISwipeActionsConfiguration(actions: [delete])
    }
}
