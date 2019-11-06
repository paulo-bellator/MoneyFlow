//
//  AddSettingsEntityViewController.swift
//  MoneyFlow
//
//  Created by Никита Гончаров on 05/11/2019.
//  Copyright © 2019 Никита Гончаров. All rights reserved.
//

import UIKit

protocol AddSettingsEntityViewControllerDelegate: class {
    func settingsEntityAdded(type: SettingsEntityType, name: String)
}
class AddSettingsEntityViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var itemNameTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    
    weak var delegate: AddSettingsEntityViewControllerDelegate?
    var settingsType: SettingsEntityType!
    private var usedNames = [String]()
    
    @IBAction func saveButtonTouched(_ sender: UIBarButtonItem) {
        itemNameTextField.superview!.layer.borderWidth = 0.0
        errorLabel.isHidden = true
        
        if let name = itemNameTextField.text, name.trailingSpacesTrimmed != "", !usedNames.contains(name.trailingSpacesTrimmed) {
            delegate?.settingsEntityAdded(type: settingsType, name: name.trailingSpacesTrimmed)
            dismiss(animated: true)
        } else {
            itemNameTextField.superview!.layer.borderWidth = 1.0
            itemNameTextField.superview!.layer.borderColor = #colorLiteral(red: 0.9333333333, green: 0.4078431373, blue: 0.4509803922, alpha: 1)
            if usedNames.contains((itemNameTextField.text ?? "").trailingSpacesTrimmed) {
                errorLabel.text = "Элемент c таким именем уже существует."
                errorLabel.isHidden = false
            } else {
                errorLabel.text = "Имя не должно быть пустым или состоять из одних пробелов."
                errorLabel.isHidden = false
            }
            itemNameTextField.becomeFirstResponder()
        }
    }
    
    @IBAction func cancelButtonTouched(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let presenter = SettingEditingPresenter.shared
        switch settingsType! {
        case .accounts:
            usedNames = presenter.accounts.map { $0.name }
            titleLabel.text = "Название счета"
        case .incomeCategories:
            usedNames = presenter.incomeCategories.map { $0.name }
            titleLabel.text = "Название категории"
        case .outcomeCategories:
            usedNames = presenter.outcomeCategories.map { $0.name }
            titleLabel.text = "Название категории"
        case .contacts:
            usedNames = presenter.contacts.map { $0.name }
            titleLabel.text = "Название контакта"
        default: break
        }
        
        itemNameTextField.becomeFirstResponder()
    }
    


}
