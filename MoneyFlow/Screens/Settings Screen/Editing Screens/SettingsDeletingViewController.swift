//
//  SettingsDeletingViewController.swift
//  MoneyFlow
//
//  Created by Никита Гончаров on 05/11/2019.
//  Copyright © 2019 Никита Гончаров. All rights reserved.
//

import UIKit

protocol SettingsDeletingViewControllerDelegate: class {
    func settingEntityDeleted(type: SettingsEntityType, deletedItem: String, moveIntoItem: String)
}

class SettingsDeletingViewController: UIViewController {

    @IBOutlet weak var deletingItemTitleLabel: UILabel!
    @IBOutlet weak var moveIntoItemTitleLabel: UILabel!
    @IBOutlet weak var deletingInfoSubtitleLabel: UILabel!
    @IBOutlet weak var moveIntoInfoSubtitleLabel: UILabel!
    @IBOutlet weak var deletingItemTextField: UITextField!
    @IBOutlet weak var moveIntoItemTextField: UITextField!
    
    weak var delegate: SettingsDeletingViewControllerDelegate?
    var settingsType: SettingsEntityType!
    var deletingItemName: String!
    private(set) var moveIntoItemsNames = [String]()
    
    private lazy var pickerView: UIPickerView = {
        let picker = UIPickerView()
        picker.dataSource = self
        picker.delegate = self
        return picker
    }()
    
    @IBAction func saveButtonTouched(_ sender: UIBarButtonItem) {
        moveIntoItemTextField.superview!.layer.borderWidth = 0.0
        if let moveIntoItemName = moveIntoItemTextField.text,
            moveIntoItemName.trailingSpacesTrimmed != "",
            moveIntoItemsNames.contains(moveIntoItemName.trailingSpacesTrimmed) {
            view.endEditing(true)
            showConfirmActionSheet()
        } else {
            moveIntoItemTextField.superview!.layer.borderWidth = 1.0
            moveIntoItemTextField.superview!.layer.borderColor = #colorLiteral(red: 0.9333333333, green: 0.4078431373, blue: 0.4509803922, alpha: 1)
        }
    }
    
    @IBAction func cancelButtonTouched(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        moveIntoItemTextField.inputView = pickerView
        deletingItemTextField.text = deletingItemName

        let presenter = SettingEditingPresenter.shared
        switch settingsType! {
        case .accounts:
            moveIntoItemsNames = presenter.accounts.compactMap { $0.name != deletingItemName ? $0.name : nil }
            deletingItemTitleLabel.text = "Удаляемый счет"
            deletingInfoSubtitleLabel.text = "Все операции с данным счетом будут перенесены, а сам счет удален."
            moveIntoItemTitleLabel.text = "Счет для переноса"
            moveIntoInfoSubtitleLabel.text = "На этот счет будут перенесены операции с удаляемого счета."
        case .incomeCategories:
            moveIntoItemsNames = presenter.incomeCategories.compactMap { $0.name != deletingItemName ? $0.name : nil }
        case .outcomeCategories:
            moveIntoItemsNames = presenter.outcomeCategories.compactMap { $0.name != deletingItemName ? $0.name : nil }
        case .contacts:
            moveIntoItemsNames = presenter.contacts.compactMap { $0.name != deletingItemName ? $0.name : nil }
            deletingItemTitleLabel.text = "Удаляемый контакт"
            deletingInfoSubtitleLabel.text = "Все операции с данным контактом будут перенесены, а сам контакт удален."
            moveIntoItemTitleLabel.text = "Контакт для переноса"
            moveIntoInfoSubtitleLabel.text = "На этот контакт будут перенесены операции с удаляемого контакта."
        default: break
        }
        moveIntoItemTextField.text = moveIntoItemsNames.first
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        moveIntoItemTextField.becomeFirstResponder()
    }
    
    private func showConfirmActionSheet() {
        var systemEntityName = "категорию"
        switch settingsType {
        case .accounts: systemEntityName = "счет"
        case.contacts: systemEntityName = "контакт"
        default: break
        }
        let title = "Подтвердите удаление"
        let message = "Данное действие необратимо. Вы не сможете отменить его или восстановить данные в дальнейшем."
        let actionSheet = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        let signOutAction = UIAlertAction(title: "Удалить " + systemEntityName, style: .destructive) { [weak self] _ in
            guard self != nil else { return }
            let moveIntoItemName = self!.moveIntoItemTextField.text!.trailingSpacesTrimmed
            self!.delegate?.settingEntityDeleted(type: self!.settingsType, deletedItem: self!.deletingItemName, moveIntoItem: moveIntoItemName)
            self!.dismiss(animated: true)
        }
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
        actionSheet.addAction(signOutAction)
        actionSheet.addAction(cancelAction)
        self.present(actionSheet, animated: true, completion: nil)
    }
    

}

extension SettingsDeletingViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return moveIntoItemsNames.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return moveIntoItemsNames[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        moveIntoItemTextField.text = moveIntoItemsNames[row]
    }
}
