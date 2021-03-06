//
//  InputAccessoryForTextFieldsVC Extension.swift
//  MoneyFlow
//
//  Created by Никита Гончаров on 09/09/2019.
//  Copyright © 2019 Никита Гончаров. All rights reserved.
//

import UIKit

extension UIViewController {
    func addInputAccessoryForTextFields(textFields: [UITextField], titles: [String] = [], dismissable: Bool = true, previousNextable: Bool = false, doneAction: Selector? = nil) {
        for (index, textField) in textFields.enumerated() {
            let toolbar: UIToolbar = UIToolbar()
            toolbar.sizeToFit()
            
            var items = [UIBarButtonItem]()
            if previousNextable {
                let previousIcon = #imageLiteral(resourceName: "arrow_top_icon")
                let previousButton = UIBarButtonItem(image: nil, style: .plain, target: nil, action: nil)
                var title = "Назад"
                if index > 0 {
                    if index < titles.count { title = titles[index-1] }
                } else { title = "" }
                
                previousButton.title = title
                previousButton.tintColor = UIColor.black
                previousButton.width = 30
                if textField == textFields.first {
                    previousButton.isEnabled = false
                } else {
                    previousButton.target = textFields[index - 1]
                    previousButton.action = #selector(UITextField.becomeFirstResponder)
                }
                let nextIcon = #imageLiteral(resourceName: "arrow_bottom_icon")
                let nextButton = UIBarButtonItem(image: nil, style: .plain, target: nil, action: nil)
                title = "Вперед"
                if index < textFields.count-1 {
                    if index < titles.count { title = titles[index+1] }
                } else { title = "" }
                nextButton.title = title
                nextButton.tintColor = UIColor.black
                nextButton.width = 30
                if textField == textFields.last {
                    nextButton.isEnabled = false
                } else {
                    nextButton.target = textFields[index + 1]
                    nextButton.action = #selector(UITextField.becomeFirstResponder)
                }
                items.append(contentsOf: [previousButton, nextButton])
            }
            
            let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            let doneSelector = doneAction ?? #selector(UIView.endEditing)
            let doneTarget = doneAction != nil ? self : view
            let doneButton = UIBarButtonItem(title: "Закрыть", style: .done, target: doneTarget, action: doneSelector)
            doneButton.tintColor = UIColor.black
            items.append(contentsOf: [spacer, doneButton])
            
            toolbar.setItems(items, animated: false)
            
//            toolbar.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
//            toolbar.setShadowImage(UIImage(), forToolbarPosition: .any)
            toolbar.barTintColor = UIColor.white
            textField.inputAccessoryView = toolbar
        }
    }
}
