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
    func updateData()
}

class AddOperationViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var valueTextField: UITextField!
    @IBOutlet weak var accountTextField: UITextField!
    @IBOutlet weak var categoryOrContactTextField: UITextField!
    @IBOutlet weak var categoryOrContactEmojiLabel: UILabel!
    @IBOutlet weak var currencySignButton: UIButton!
    @IBOutlet weak var visibleView: UIView!
    
    weak var delegate: AddOperationViewControllerDelegate?
    let presenter = Presenter()
    let settingsPresenter = SettingsPresenter.shared
    
    private lazy var pickerView: UIPickerView = {
        let picker = UIPickerView()
        picker.frame.size.height = 226
        picker.dataSource = self
        picker.delegate = self
        return picker
    }()
    private lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.frame.size.height = 226
        picker.locale = Locale(identifier: "ru_RU")
        picker.datePickerMode = .dateAndTime
        picker.date = Date()
        picker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        return picker
    }()
    
    var isItFlowOperations = true
    private var currentCurrencyIndex = 0 {
        didSet {
            if currentCurrencyIndex >= settingsPresenter.currencies.count { currentCurrencyIndex = 0 }
            print(currentCurrencyIndex)
        }
    }

   
    @IBAction func currencyButtonTouched(_ sender: UIButton) {
        currentCurrencyIndex += 1
        sender.setTitle(settingsPresenter.currenciesSignes[currentCurrencyIndex], for: .normal)
    }
    
    @IBAction func addButtonTouched(_ sender: UIButton) {
        addOperation()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dateTextField.inputView = datePicker
        dateTextField.text = Date().formattedDescription
        valueTextField.text = ""
        accountTextField.inputView = pickerView
        accountTextField.text = settingsPresenter.accounts.first
        accountTextField.delegate = self
        categoryOrContactTextField.inputView = pickerView
        categoryOrContactTextField.text = settingsPresenter.categories.first
        categoryOrContactTextField.delegate = self
        currencySignButton.titleLabel?.text = settingsPresenter.currenciesSignes.first
        
        Timer.scheduledTimer(withTimeInterval: 0.4, repeats: false) { [weak self] (_) in
            self?.valueTextField.becomeFirstResponder()
        }
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapGestureRecognized(recognizer:)))
        view.addGestureRecognizer(gestureRecognizer)
        
        addInputAccessoryForTextFields(
            textFields: [dateTextField, valueTextField, accountTextField, categoryOrContactTextField],
            titles: ["Дата", "Значение", "Счет", isItFlowOperations ? "Категория" : "Контакт"],
            dismissable: true,
            previousNextable: true,
            doneAction: #selector(AddOperationViewController.addOperation))
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        pickerView.reloadAllComponents()
    }
    
    @objc private func tapGestureRecognized(recognizer: UITapGestureRecognizer) {
        let tapPoint = recognizer.location(in: view)
        if !visibleView.frame.contains(tapPoint) {
            dismiss()
        }
    }
    
    @objc func addOperation() {
        var operation: Operation
        let date = datePicker.date
        let value = Double(valueTextField.text ?? "") ?? 0.0
        let currency = Currency(rawValue: currencySignButton.currentTitle!) ?? settingsPresenter.currencies.first!
        let account = accountTextField.text!
        let categoryOrContact = categoryOrContactTextField.text!
        let comment: String? = nil
        
        if isItFlowOperations {
            operation = FlowOperation(date: date, value: value, currency: currency, category: categoryOrContact, account: account, comment: comment)
        } else {
            operation = DebtOperation(date: date, value: value, currency: currency, contact: categoryOrContact, account: account, comment: comment)
        }
        presenter.add(operation: operation)
        delegate?.updateData()
        dismiss()
    }
    
    private func dismiss() {
        view.endEditing(true)
        self.dismiss(animated: true)
        delegate?.removeBlurredBackgroundView()
    }
    
    @objc private func datePickerValueChanged() {
        dateTextField.text = datePicker.date.formattedDescription
    }
    
}


