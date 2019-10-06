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
    
    // MARK: Outlets
    
    @IBOutlet weak var operationTypeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var valueTextField: UITextField!
    @IBOutlet weak var accountTextField: UITextField!
    @IBOutlet weak var categoryOrContactTextField: UITextField!
    @IBOutlet weak var currencySignButton: UIButton!
    @IBOutlet weak var valueSignButton: UIButton!
    @IBOutlet weak var debtDirectionSegmentedControl: UISegmentedControl!
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var categoryOrContactLabel: UILabel!
    @IBOutlet weak var bottomViewTopSafeAreaConstraint: NSLayoutConstraint!
    
//    @IBOutlet weak var addMoreButton: UIButton!
    
    
    // MARK: Properties
    
    weak var delegate: AddOperationViewControllerDelegate?
    let presenter = AddOperationPresenter()
    
    var currentPickerRowForCategoryOrContact = 0
    var currentPickerRowForAccount = 0
    private lazy var viewFrameOriginY: CGFloat = self.view.frame.origin.y
    
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
    
    private(set) var isItIncomeOperation = true {
        didSet {
            if isItIncomeOperation != oldValue && isItFlowOperation {
                let color = isItIncomeOperation ? Constants.incomeOperationTypeColor : Constants.outcomeOperationTypeColor
                if #available(iOS 13.0, *) { operationTypeSegmentedControl.selectedSegmentTintColor = color }
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
            debtDirectionSegmentedControl.isHidden.toggle()
            valueSignButton.superview!.isHidden.toggle()
            
            currentPickerRowForCategoryOrContact = 0
            categoryOrContactLabel.text = isItFlowOperation ? Constants.categoryTitle : Constants.contactTitle
            var value: String?
            if isItFlowOperation {
                value = (isItIncomeOperation ? presenter.incomeCategories : presenter.outcomeCategories).first
            } else { value = presenter.contacts.first }
            categoryOrContactTextField.text = value
            pickerView.selectRow(0, inComponent: 0, animated: false)
        }
    }
    private var currentCurrencyIndex = 0 {
        didSet {
            if currentCurrencyIndex >= presenter.currencies.count { currentCurrencyIndex = 0 }
        }
    }
    
    // MARK: Outlet functions
    
    @IBAction func operationTypeSwitched(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            isItFlowOperation = true
            let color = isItIncomeOperation ? Constants.incomeOperationTypeColor : Constants.outcomeOperationTypeColor
            if #available(iOS 13.0, *) { sender.selectedSegmentTintColor = color }
        } else {
            isItFlowOperation = false
            if #available(iOS 13.0, *) { sender.selectedSegmentTintColor = Constants.debtOperationTypeColor }
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
        if (valueTextField.text?.isEmpty ?? true) {
            valueTextField.superview!.layer.borderWidth = 1.0
            valueTextField.superview!.layer.borderColor = #colorLiteral(red: 0.9333333333, green: 0.4078431373, blue: 0.4509803922, alpha: 1)
        } else {
            addOperation()
            print("done")
        }
        
    }
    
    
//    @IBAction func addButtonTouched(_ sender: UIButton) {
//        addOperation()
//    }
    
//    @IBAction func addMoreButtonTouched(_ sender: UIButton) {
//    }
    
    // MARK: ViewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        valueSignButton.superview!.isHidden = false
        debtDirectionSegmentedControl.isHidden = true
        
        if #available(iOS 13.0, *) {
            operationTypeSegmentedControl.selectedSegmentTintColor = Constants.incomeOperationTypeColor
            operationTypeSegmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        }
        
        
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
            doneAction: #selector(AddOperationViewController.dismissKeyboard))
        
         NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // MARK: Working with text fields and input
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if bottomViewTopSafeAreaConstraint.constant != 0 {
            offsetFields(by: 0)
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        pickerView.reloadAllComponents()
        if valueTextField.isFirstResponder {
            offsetFields(by: 0)
        }
        if accountTextField.isFirstResponder {
            pickerView.selectRow(currentPickerRowForAccount, inComponent: 0, animated: false)
            offsetFields(by: 0)
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
    
    private func offsetFields(by offset: CGFloat) {
        let currentOffset = bottomViewTopSafeAreaConstraint.constant
        var duration = Double(abs(offset - currentOffset) / Constants.viewsOffsetSpeed)
        duration = max(duration, Constants.viewsOffsetMinimumDuration)
        UIView.animate(withDuration: duration) {
            self.bottomViewTopSafeAreaConstraint.constant = offset
            self.view.layoutIfNeeded()
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if !(valueTextField.text?.isEmpty ?? true) {
            valueTextField.superview!.layer.borderWidth = 0.0
        }
    }
    
    @objc private func datePickerValueChanged() {
        dateTextField.text = datePicker.date.formattedDescription
    }
    
    // MARK: Main functions
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func addOperation() {
        var operation: Operation
        let date = datePicker.date
        
        var sign = "-"
        if isItFlowOperation { sign = valueSignButton.titleLabel?.text ?? "-" }
        else { sign = debtDirectionSegmentedControl.selectedSegmentIndex == 0 ? "-" : "+" }
        let valueSign = (sign == "+") ? 1.0 : -1.0
        
        let value = (Double(valueTextField.text ?? "") ?? 0.0) * valueSign
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
        print(operation)
        presenter.add(operation: operation)
        delegate?.updateData()
        dismiss()
    }
    
    private func dismiss() {
        view.endEditing(true)
        self.dismiss(animated: true)
        delegate?.removeBlurredBackgroundView()
    }
    
}

extension AddOperationViewController {
    struct Constants {
        static let incomeOperationTypeColor = #colorLiteral(red: 0.7333333333, green: 0.8352941176, blue: 0.6705882353, alpha: 1)
        static let outcomeOperationTypeColor = #colorLiteral(red: 0.9568627451, green: 0.6941176471, blue: 0.5137254902, alpha: 1)
        static let debtOperationTypeColor = #colorLiteral(red: 0.4, green: 0.462745098, blue: 0.9529411765, alpha: 1)
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


