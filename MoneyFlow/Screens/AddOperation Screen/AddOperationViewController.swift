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
    @IBOutlet weak var currencySignButton: UIButton!
    @IBOutlet weak var valueSignButton: UIButton!
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var categoryOrContactLabel: UILabel!
    @IBOutlet weak var bottomViewTopSafeAreaConstraint: NSLayoutConstraint!
    
//    @IBOutlet weak var addMoreButton: UIButton!
    
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
    private lazy var viewFrameOriginY: CGFloat = self.view.frame.origin.y
    
    private(set) var isItIncomeOperation = true {
        didSet {
            if isItIncomeOperation != oldValue && isItFlowOperation {
                currentPickerRowForCategoryOrContact = 0
                categoryOrContactTextField.text = (isItIncomeOperation ? presenter.incomeCategories : presenter.outcomeCategories).first
                if categoryOrContactTextField.isFirstResponder {
                    pickerView.reloadAllComponents()
                    pickerView.selectRow(0, inComponent: 0, animated: true)
                }
            }
        }
    }
    private(set) var isItFlowOperation = true {
        didSet {
            currentPickerRowForCategoryOrContact = 0
//            operationTypeView.fillColor = isItFlowOperation ? Constants.flowOperationTypeColor : Constants.debtOperationTypeColor
            pickerView.selectRow(0, inComponent: 0, animated: false)
        }
    }
    private var currentCurrencyIndex = 0 {
        didSet {
            if currentCurrencyIndex >= presenter.currencies.count { currentCurrencyIndex = 0 }
        }
    }

    @IBAction func valueSignButtonTouched(_ sender: UIButton) {
        let currentSign = valueSignButton.titleLabel?.text ?? ""
        print(currentSign)
        switch currentSign {
        case "+":
            sender.setTitle("-", for: .normal)
            isItIncomeOperation = false
        case "-":
            sender.setTitle("+", for: .normal)
            isItIncomeOperation = true
        default:
            sender.setTitle("+", for: .normal)
            isItIncomeOperation = true
        }
    }
    
    @IBAction func currencyButtonTouched(_ sender: UIButton) {
        currentCurrencyIndex += 1
        sender.setTitle(presenter.currenciesSignes[currentCurrencyIndex], for: .normal)
    }
    
    @IBAction func doneButtonTouched(_ sender: UIBarButtonItem) {
        addOperation()
    }
    
    
//    @IBAction func addButtonTouched(_ sender: UIButton) {
//        addOperation()
//    }
    
//    @IBAction func addMoreButtonTouched(_ sender: UIButton) {
//    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        isItFlowOperations = true
        dateTextField.inputView = datePicker
        dateTextField.text = Date().formattedDescription
        dateTextField.delegate = self
        valueTextField.text = ""
        valueTextField.delegate = self
        accountTextField.inputView = pickerView
        accountTextField.text = presenter.accounts.first
        accountTextField.delegate = self
        categoryOrContactTextField.inputView = pickerView
        categoryOrContactTextField.text = (isItIncomeOperation ? presenter.incomeCategories : presenter.outcomeCategories).first
        categoryOrContactTextField.delegate = self
        currencySignButton.setTitle(presenter.currenciesSignes.first, for: .normal)
        commentTextField.text = nil
        commentTextField.delegate = self
        
        Timer.scheduledTimer(withTimeInterval: Constants.becomeFirstResponderDelay, repeats: false) { [weak self] (_) in
            self?.valueTextField.becomeFirstResponder()
        }
        
        addInputAccessoryForTextFields(
            textFields: [valueTextField, accountTextField, categoryOrContactTextField, dateTextField, commentTextField],
            titles: [Constants.valueTitle,
                     Constants.accountTitle,
                     isItFlowOperation ? Constants.categoryTitle : Constants.contactTitle,
                     Constants.dataTitle,
                     Constants.commentTitle],
            dismissable: true,
            previousNextable: true,
            doneAction: #selector(AddOperationViewController.addOperation))
        
         NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if bottomViewTopSafeAreaConstraint.constant != 0 {
            offsetFields(by: 0)
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        pickerView.reloadAllComponents()
        if accountTextField.isFirstResponder {
            pickerView.selectRow(currentPickerRowForAccount, inComponent: 0, animated: false)
        }
        if categoryOrContactTextField.isFirstResponder {
            pickerView.selectRow(currentPickerRowForCategoryOrContact, inComponent: 0, animated: false)
            offsetFields(by: Constants.offsetForCategoryField)
        }
        if dateTextField.isFirstResponder  {
            offsetFields(by: Constants.offsetForDateField)
        }
        if commentTextField.isFirstResponder {
            offsetFields(by: Constants.offsetForCommentField)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == valueTextField {
            let value = Double(valueTextField.text ?? "") ?? 0.0
            if isItIncomeOperation != (value >= 0) { isItIncomeOperation.toggle() }
//            print(isItIncomeOperation)
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
    
    private func offsetFields(by offset: CGFloat) {
        let currentOffset = bottomViewTopSafeAreaConstraint.constant
        var duration = Double(abs(offset - currentOffset) / Constants.viewsOffsetSpeed)
        duration = max(duration, Constants.viewsOffsetMinimumDuration)
        UIView.animate(withDuration: duration) {
            self.bottomViewTopSafeAreaConstraint.constant = offset
            self.view.layoutIfNeeded()
        }
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
        static let viewsOffsetSpeed: CGFloat = 250 / 0.4
        static let viewsOffsetMinimumDuration = 0.3
        static let returnToOriginStateOffsetDuration = 0.2
        static let offsetForCategoryField: CGFloat = -100
        static let offsetForDateField: CGFloat = -200
        static let offsetForCommentField: CGFloat = -250
    }
}


