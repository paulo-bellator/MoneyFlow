//
//  ManagingPickerView Extension.swift
//  MoneyFlow
//
//  Created by Никита Гончаров on 09/09/2019.
//  Copyright © 2019 Никита Гончаров. All rights reserved.
//

import UIKit

extension AddOperationViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if accountTextField.isFirstResponder {
            return settingsPresenter.accounts.count
        } else if categoryOrContactTextField.isFirstResponder {
            return isItFlowOperations ? settingsPresenter.categories.count : settingsPresenter.contacts.count
        }
        return 10
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if accountTextField.isFirstResponder {
            return settingsPresenter.accounts[row]
        } else if categoryOrContactTextField.isFirstResponder {
            return isItFlowOperations ? settingsPresenter.categories[row] : settingsPresenter.contacts[row]
        }
        return "Empty"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if accountTextField.isFirstResponder {
            accountTextField.text = settingsPresenter.accounts[row]
        } else if categoryOrContactTextField.isFirstResponder {
            if isItFlowOperations {
                categoryOrContactTextField.text = settingsPresenter.categories[row]
                categoryOrContactEmojiLabel.text = settingsPresenter.emojiFor(category: settingsPresenter.categories[row])
            } else {
                categoryOrContactTextField.text = settingsPresenter.contacts[row]
                categoryOrContactEmojiLabel.text = settingsPresenter.emojiFor(contact: settingsPresenter.contacts[row])
            }
        }
    }
}
