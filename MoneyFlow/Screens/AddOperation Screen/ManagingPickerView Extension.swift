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
            return presenter.accounts.count
        } else if categoryOrContactTextField.isFirstResponder {
            let categoriesCount = isItIncomeOperation ? presenter.incomeCategories.count : presenter.outcomeCategories.count
            return isItFlowOperation ? categoriesCount : presenter.contacts.count
        }
        return 10
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if accountTextField.isFirstResponder {
            return presenter.accounts[row]
        } else if categoryOrContactTextField.isFirstResponder {
            let categories = isItIncomeOperation ? presenter.incomeCategories : presenter.outcomeCategories
            return isItFlowOperation ? categories[row] : presenter.contacts[row]
        }
        return Constants.pickerViewTitlePlaceHolder
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if accountTextField.isFirstResponder {
            accountTextField.text = presenter.accounts[row]
            currentPickerRowForAccount = row
        } else if categoryOrContactTextField.isFirstResponder {
            currentPickerRowForCategoryOrContact = row
            if isItFlowOperation {
                let categories = isItIncomeOperation ? presenter.incomeCategories : presenter.outcomeCategories
                categoryOrContactTextField.text = categories[row]
            } else {
                categoryOrContactTextField.text = presenter.contacts[row]
            }
        }
    }
}
