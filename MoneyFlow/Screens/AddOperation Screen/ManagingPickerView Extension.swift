//
//  ManagingPickerView Extension.swift
//  MoneyFlow
//
//  Created by Никита Гончаров on 09/09/2019.
//  Copyright © 2019 Никита Гончаров. All rights reserved.
//

import UIKit

extension AddOperationViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    var accountsForDebts: [String] {
        return [Constants.titles.emptyAccount] + presenter.accounts
    }
    var accounts: [String] {
        switch operationType {
        case .debt: return accountsForDebts
        default: return presenter.accounts
        }
    }
    var specialValues: [String] {
        switch operationType {
        case .flow(.positive): return presenter.incomeCategories
        case .flow(.negative): return presenter.outcomeCategories
        case .debt: return presenter.contacts
        case .transfer: return presenter.accounts
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if accountTextField.isFirstResponder {
            return accounts.count
        } else if specialFieldTextField.isFirstResponder {
            return specialValues.count
        }
        return 10
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if accountTextField.isFirstResponder {
            return accounts[row]
        } else if specialFieldTextField.isFirstResponder {
            return specialValues[row]
        }
        return Constants.titles.pickerViewTitlePlaceHolder
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if accountTextField.isFirstResponder {
            if operationType == .debt {
                let switchedToEmpty = currentPickerRowForAccount != 0 && row == 0
                let title0 = switchedToEmpty ? Constants.titles.debtWillGive : Constants.titles.debtGive
                let title1 = switchedToEmpty ? Constants.titles.debtWillGet : Constants.titles.debtGet
                debtDirectionSegmentedControl.setTitle(title0, forSegmentAt: 0)
                debtDirectionSegmentedControl.setTitle(title1, forSegmentAt: 1)
            }
            accountTextField.text = accounts[row]
            currentPickerRowForAccount = row
        } else if specialFieldTextField.isFirstResponder {
            currentPickerRowForSpecialField = row
            specialFieldTextField.text = specialValues[row]
        }
    }
}
