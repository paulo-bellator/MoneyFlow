//
//  SettingsEditingNameViewController.swift
//  MoneyFlow
//
//  Created by Никита Гончаров on 03/11/2019.
//  Copyright © 2019 Никита Гончаров. All rights reserved.
//

import UIKit

protocol SettingsEditingNameViewControllerDelegate: class {
    func settingEntityRenamed(type: SettingsEntityType, oldValue: String, newValue: String)
}

class SettingsEditingNameViewController: UIViewController {
    
    @IBOutlet weak var currentNameTextField: UITextField!
    @IBOutlet weak var underCurrentNameMessageLabel: UILabel!
    @IBOutlet weak var newNameTextField: UITextField!
    @IBOutlet weak var underNewNameErrorLabel: UILabel!
    
    weak var delegate: SettingsEditingNameViewControllerDelegate?
    var settingsType: SettingsEntityType!
    var currentValue: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        currentNameTextField.text = currentValue
        var message = ""
        switch settingsType! {
        case .accounts:
            message = "Cчет так же будет переименован во всех операциях, относящихся к нему."
        case .incomeCategories, .outcomeCategories:
            message = "Категория так же будет переименована во всех операциях, относящихся к ней."
        case .contacts:
            message = "Контакт так же будет переименован во всех операциях, относящихся к нему."
        default:
            message = "Элемент так же будет переименован во всех операциях, относящихся к нему."
        }
        underCurrentNameMessageLabel.text = message
        newNameTextField.becomeFirstResponder()
    }
    
    @IBAction func saveButtonTouched(_ sender: UIBarButtonItem) {
        newNameTextField.superview!.layer.borderWidth = 0.0
        underNewNameErrorLabel.isHidden = true
        
        if let newName = newNameTextField.text, newName != "", newName != currentValue {
            delegate?.settingEntityRenamed(type: settingsType, oldValue: currentValue, newValue: newName)
            dismiss(animated: true)
        } else {
            newNameTextField.superview!.layer.borderWidth = 1.0
            newNameTextField.superview!.layer.borderColor = #colorLiteral(red: 0.9333333333, green: 0.4078431373, blue: 0.4509803922, alpha: 1)
            if newNameTextField.text == currentValue {
                underNewNameErrorLabel.text = "New name should not be the same as current name."
                underNewNameErrorLabel.isHidden = false
            }
            newNameTextField.becomeFirstResponder()
        }
    }
    @IBAction func cancelButtonTouched(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    

}
