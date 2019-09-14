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
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var visibleView: UIView!
    @IBOutlet weak var operationTypeView: RoundedSoaringView!
    @IBOutlet weak var addMoreButton: UIButton!
    
    weak var delegate: AddOperationViewControllerDelegate?
    let presenter = AddOperationPresenter()
    
    private lazy var pickerView: UIPickerView = {
        let picker = UIPickerView()
        picker.frame.size.height = Constants.pickerHeight
        picker.dataSource = self
        picker.delegate = self
        return picker
    }()
    private lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.frame.size.height = Constants.pickerHeight
        picker.locale = Locale(identifier: Constants.localeIdentifier)
        picker.datePickerMode = .dateAndTime
        picker.date = Date()
        picker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        return picker
    }()
    
    var currentPickerRowForCategoryOrContact = 0
    var currentPickerRowForAccount = 0
    
    private(set) var isItIncomeOperation = true {
        didSet {
            if isItIncomeOperation != oldValue && isItFlowOperation {
                currentPickerRowForCategoryOrContact = 0
                categoryOrContactTextField.text = (isItIncomeOperation ? presenter.incomeCategories : presenter.outcomeCategories).first
                categoryOrContactEmojiLabel.text = presenter.emojiFor(category: categoryOrContactTextField.text ?? "")
            }
        }
    }
    private(set) var isItFlowOperation = true {
        didSet {
            currentPickerRowForCategoryOrContact = 0
            operationTypeView.fillColor = isItFlowOperation ? Constants.flowOperationTypeColor : Constants.debtOperationTypeColor
            pickerView.selectRow(0, inComponent: 0, animated: false)
            UIView.transition(
                with: visibleView,
                duration: Constants.operationTypeAnimationTransitionDuration,
                options: isItFlowOperation ? .transitionFlipFromLeft : .transitionFlipFromRight,
                animations: { [unowned self] in
                    self.pickerView.reloadAllComponents()
                    let categories = self.isItIncomeOperation ? self.presenter.incomeCategories : self.presenter.outcomeCategories
                    self.categoryOrContactTextField.text = self.isItFlowOperation ? categories.first! : self.presenter.contacts.first!
                    if self.isItFlowOperation {
                        self.categoryOrContactEmojiLabel.text = self.presenter.emojiFor(category: self.categoryOrContactTextField.text ?? "")
                    } else {
                        self.categoryOrContactEmojiLabel.text =  self.presenter.emojiFor(contact: self.categoryOrContactTextField.text ?? "")
                    }
                    
            }) { [unowned self] (_) in
                self.valueTextField.becomeFirstResponder()
                var toolBar = self.accountTextField.inputAccessoryView as! UIToolbar
                var nextButton = toolBar.items![1]
                nextButton.title = self.isItFlowOperation ? Constants.categoryTitle : Constants.contactTitle
                toolBar = self.commentTextField.inputAccessoryView as! UIToolbar
                nextButton = toolBar.items![0]
                nextButton.title = self.isItFlowOperation ? Constants.categoryTitle : Constants.contactTitle
            }
        }
    }
    private var currentCurrencyIndex = 0 {
        didSet {
            if currentCurrencyIndex >= presenter.currencies.count { currentCurrencyIndex = 0 }
        }
    }

   
    @IBAction func currencyButtonTouched(_ sender: UIButton) {
        currentCurrencyIndex += 1
        sender.setTitle(presenter.currenciesSignes[currentCurrencyIndex], for: .normal)
    }
    
    @IBAction func addButtonTouched(_ sender: UIButton) {
        addOperation()
    }
    
    @IBAction func addMoreButtonTouched(_ sender: UIButton) {
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        isItFlowOperations = true
        dateTextField.inputView = datePicker
        dateTextField.text = Date().formattedDescription
        valueTextField.text = ""
        valueTextField.delegate = self
        accountTextField.inputView = pickerView
        accountTextField.text = presenter.accounts.first
        accountTextField.delegate = self
        categoryOrContactTextField.inputView = pickerView
        categoryOrContactTextField.text = (isItIncomeOperation ? presenter.incomeCategories : presenter.outcomeCategories).first
        categoryOrContactEmojiLabel.text = presenter.emojiFor(category: categoryOrContactTextField.text ?? "")
        categoryOrContactTextField.delegate = self
        currencySignButton.titleLabel?.text = presenter.currenciesSignes.first
        commentTextField.text = nil
        
        Timer.scheduledTimer(withTimeInterval: Constants.becomeFirstResponderDelay, repeats: false) { [weak self] (_) in
            self?.valueTextField.becomeFirstResponder()
        }
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapGestureRecognized(recognizer:)))
        view.addGestureRecognizer(gestureRecognizer)
        
        addInputAccessoryForTextFields(
            textFields: [dateTextField, valueTextField, accountTextField, categoryOrContactTextField, commentTextField],
            titles: [Constants.dataTitle,
                     Constants.valueTitle,
                     Constants.accountTitle,
                     isItFlowOperation ? Constants.categoryTitle : Constants.contactTitle,
                     Constants.commentTitle],
            dismissable: true,
            previousNextable: true,
            doneAction: #selector(AddOperationViewController.addOperation))
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        pickerView.reloadAllComponents()
        if accountTextField.isFirstResponder { pickerView.selectRow(currentPickerRowForAccount, inComponent: 0, animated: false) }
        if categoryOrContactTextField.isFirstResponder { pickerView.selectRow(currentPickerRowForCategoryOrContact, inComponent: 0, animated: false)  }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == valueTextField {
            let value = Double(valueTextField.text ?? "") ?? 0.0
            if isItIncomeOperation != (value >= 0) { isItIncomeOperation.toggle() }
//            print(isItIncomeOperation)
        }
    }
    
    
    
    @objc private func tapGestureRecognized(recognizer: UITapGestureRecognizer) {
        let tapPoint = recognizer.location(in: view)
        
        switch tapPoint {
        case _ where visibleView.frame.contains(tapPoint): break
        case _ where addMoreButton.frame.contains(tapPoint): break
        case _ where operationTypeView.frame.contains(tapPoint):
            isItFlowOperation.toggle()
            
        default: dismiss()
        }
    }
    
    @objc func addOperation() {
        var operation: Operation
        let date = datePicker.date
        let value = Double(valueTextField.text ?? "") ?? 0.0
        let currency = Currency(rawValue: currencySignButton.currentTitle!) ?? presenter.currencies.first!
        let account = accountTextField.text!
        let categoryOrContact = categoryOrContactTextField.text!
        var comment = commentTextField.text
        if comment != nil { if comment!.isEmpty { comment = nil } }
        
        if isItFlowOperation {
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

extension AddOperationViewController {
    struct Constants {
        static let flowOperationTypeColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
        static let debtOperationTypeColor = #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)
        static let pickerHeight: CGFloat = 226
        static let becomeFirstResponderDelay: TimeInterval = 0.4
        static let operationTypeAnimationTransitionDuration: TimeInterval = 0.45
        static let localeIdentifier = "ru_RU"
        static let categoryTitle = "Категория"
        static let contactTitle = "Контакт"
        static let dataTitle = "Дата"
        static let valueTitle = "Значение"
        static let accountTitle = "Счет"
        static let commentTitle = "Комментарий"
        static let pickerViewTitlePlaceHolder = "Empty"
    }
}

