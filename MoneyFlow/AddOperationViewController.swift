//
//  AddOperationViewController.swift
//  MoneyFlow
//
//  Created by Никита Гончаров on 08/09/2019.
//  Copyright © 2019 Никита Гончаров. All rights reserved.
//

import UIKit

protocol AddOperationViewControllerDelegate: class {
    func removeBlurredBackgroundView()
}

class AddOperationViewController: UIViewController {
    
    weak var delegate: AddOperationViewControllerDelegate?
    
    let presenter = Presenter()
    let settingsPresenter = SettingsPresenter.shared
    private let pickerView = UIPickerView()
    private let datePicker = UIDatePicker()
    
    private var isItFlowOperations = true
    private var currentCurrencyIndex = 0 {
        didSet {
            if currentCurrencyIndex >= settingsPresenter.currencies.count { currentCurrencyIndex = 0 }
        }
    }


    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var valueTextField: UITextField!
    @IBOutlet weak var accountTextField: UITextField!
    @IBOutlet weak var categoryOrContactTextField: UITextField!
    @IBOutlet weak var categoryOrContactEmojiLabel: UILabel!
    @IBOutlet weak var currencySignButton: UIButton!
    @IBOutlet weak var visibleView: UIView!
    
    
    @IBAction func currencyButtonTouched(_ sender: UIButton) {
        currentCurrencyIndex += 1
        sender.titleLabel?.text = settingsPresenter.currenciesSignes.first
    }
    
    @IBAction func addButtonTouched(_ sender: UIButton) {
        

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pickerView.dataSource = self
        pickerView.delegate = self
        datePicker.locale = Locale(identifier: "ru_RU")
        datePicker.datePickerMode = .dateAndTime
        datePicker.date = Date()
        datePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        
        
        dateTextField.inputView = datePicker
        dateTextField.text = Date().formattedDescription
        Timer.scheduledTimer(withTimeInterval: 0.4, repeats: false) { [weak self] (_) in
            self?.valueTextField.becomeFirstResponder()
        }
//        valueTextField.becomeFirstResponder()
        accountTextField.inputView = pickerView
        accountTextField.text = settingsPresenter.accounts.first
        categoryOrContactTextField.inputView = pickerView
        categoryOrContactTextField.text = settingsPresenter.categories.first
        currencySignButton.titleLabel?.text = settingsPresenter.currenciesSignes.first
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapGestureRecognized(recognizer:)))
        view.addGestureRecognizer(gestureRecognizer)
    }
    
    @objc func tapGestureRecognized(recognizer: UITapGestureRecognizer) {
        print("dd")
        let tapPoint = recognizer.location(in: view)
        if !visibleView.frame.contains(tapPoint) {
//            resignFirstResponder()
            view.endEditing(true)
            self.dismiss(animated: true)
            delegate?.removeBlurredBackgroundView()
        }
    }
    
    @objc func datePickerValueChanged() {
        dateTextField.text = datePicker.date.formattedDescription
    }
    

}

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
