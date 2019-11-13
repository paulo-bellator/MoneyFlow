//
//  AddOperationViewController.swift
//  MoneyFlow
//
//  Created by Никита Гончаров on 08/09/2019.
//  Copyright © 2019 Никита Гончаров. All rights reserved.
//

import UIKit

protocol AddOperationViewControllerDelegate: class {
    func addedOperation(_ operation: Operation)
    func edittedOperation(_ operation: Operation)
}
extension AddOperationViewControllerDelegate {
    func edittedOperation(_ operation: Operation) {}
}

class AddOperationViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: Outlets
    
    @IBOutlet weak var operationTypeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var valueTextField: UITextField!
    @IBOutlet weak var accountTextField: UITextField!
    @IBOutlet weak var specialFieldTextField: UITextField!
    @IBOutlet weak var currencySignButton: UIButton!
    @IBOutlet weak var valueSignButton: UIButton!
    @IBOutlet weak var debtDirectionSegmentedControl: UISegmentedControl!
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var specialFieldLabel: UILabel!
    @IBOutlet weak var bottomViewTopSafeAreaConstraint: NSLayoutConstraint!
    @IBOutlet weak var commentLabel: UILabel!
    
    
    // MARK: Properties
    
    weak var delegate: AddOperationViewControllerDelegate?
    var operationToBeEditted: Operation?
    let presenter = AddOperationPresenter()
    
    var currentPickerRowForSpecialField = 0
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
        picker.maximumDate = Date() + 60*60
        picker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        return picker
    }()
    
    private(set) var operationType: OperationType = .flow(sign: .positive) {
        didSet {
            operationTypeChanged(from: oldValue, to: operationType)
        }
    }
    private var currentCurrencyIndex = 0 {
        didSet {
            if currentCurrencyIndex >= presenter.currencies.count { currentCurrencyIndex = 0 }
        }
    }
    
    // MARK: Outlet functions
    
    @IBAction func operationTypeSwitched(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            if valueSignButton.titleLabel?.text == "+" { operationType = .flow(sign: .positive) }
            else { operationType = .flow(sign: .negative) }
        case 1: operationType = .debt
        case 2: operationType = .transfer
        default: break
        }
    }
    
    @IBAction func valueSignButtonTouched(_ sender: UIButton) {
        let currentSign = valueSignButton.titleLabel?.text ?? ""
        switch currentSign {
        case "+":
            sender.setTitle("-", for: .normal)
            operationType = .flow(sign: .negative)
        case "-":
            sender.setTitle("+", for: .normal)
            operationType = .flow(sign: .positive)
        default: return
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
            valueTextField.becomeFirstResponder()
        } else {
            addOperation()
        }
    }
    @IBAction func cancelButtonTouched(_ sender: UIBarButtonItem) {
        dismiss()
    }
    
    // MARK: ViewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        valueSignButton.superview!.isHidden = false
        debtDirectionSegmentedControl.isHidden = true
        debtDirectionSegmentedControl.setTitle(Constants.titles.debtGive, forSegmentAt: 0)
        debtDirectionSegmentedControl.setTitle(Constants.titles.debtGet, forSegmentAt: 1)
        
        if #available(iOS 13.0, *) {
            operationTypeSegmentedControl.selectedSegmentTintColor = Constants.operationTypeColors.income
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
        specialFieldTextField.inputView = pickerView
        specialFieldTextField.text = (operationType.sign! == .positive ? presenter.incomeCategories : presenter.outcomeCategories).first
        specialFieldTextField.delegate = self
        currencySignButton.setTitle(presenter.currenciesSignes.first, for: .normal)
        commentTextField.text = nil
        commentTextField.delegate = self
        
        initializeIfEditMode()
        if operationToBeEditted == nil {
            Timer.scheduledTimer(withTimeInterval: Constants.becomeFirstResponderDelay, repeats: false) { [weak self] (_) in
                self?.valueTextField.becomeFirstResponder()
            }
        }
        addInputAccessoryForTextFields()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func addInputAccessoryForTextFields() {
        var textFields: [UITextField] = [valueTextField, accountTextField, specialFieldTextField, dateTextField]
        var titles = [Constants.titles.value, Constants.titles.account]
        switch operationType {
        case .flow:
            titles += [Constants.titles.category, Constants.titles.data, Constants.titles.comment]
            textFields.append(commentTextField)
        case .debt:
            titles += [Constants.titles.contact, Constants.titles.data, Constants.titles.comment]
            textFields.append(commentTextField)
        case .transfer:
            titles += [Constants.titles.toAccount, Constants.titles.data]
        }
        addInputAccessoryForTextFields(textFields: textFields, titles: titles, dismissable: true, previousNextable: true,
        doneAction: #selector(AddOperationViewController.dismissKeyboard))
    }
    
    private func initializeIfEditMode() {
        if let operation = operationToBeEditted {
            operationTypeSegmentedControl.isHidden = true
            
            switch operation {
            case let flowOp as FlowOperation:
                if flowOp.value < 0 {
                    operationType = .flow(sign: .negative)
                    currentPickerRowForSpecialField = presenter.outcomeCategories.firstIndex(of: flowOp.category) ?? 0
                } else {
                    operationType = .flow(sign: .positive)
                    currentPickerRowForSpecialField = presenter.incomeCategories.firstIndex(of: flowOp.category) ?? 0
                }
                specialFieldTextField.text = flowOp.category
                commentTextField.text = flowOp.comment
                accountTextField.text = flowOp.account
                currentPickerRowForAccount = presenter.accounts.firstIndex(of: flowOp.account) ?? 0
                
            case let debtOp as DebtOperation:
                operationType = .debt
                debtDirectionSegmentedControl.selectedSegmentIndex = (operation.value >= 0) ? 1 : 0
                let title0 = operation.account.isEmpty ? Constants.titles.debtWillGive : Constants.titles.debtGive
                let title1 = operation.account.isEmpty ? Constants.titles.debtWillGet : Constants.titles.debtGet
                debtDirectionSegmentedControl.setTitle(title0, forSegmentAt: 0)
                debtDirectionSegmentedControl.setTitle(title1, forSegmentAt: 1)
                specialFieldTextField.text = debtOp.contact
                commentTextField.text = debtOp.comment
                accountTextField.text = debtOp.account.isEmpty ? Constants.titles.emptyAccount : debtOp.account
                currentPickerRowForAccount = accountsForDebts.firstIndex(of: accountTextField.text!) ?? 0
                currentPickerRowForSpecialField = presenter.contacts.firstIndex(of: debtOp.contact) ?? 0
                
            case let transferOp as TransferOperation:
                operationType = .transfer
                specialFieldTextField.text = transferOp.destinationAccount
                accountTextField.text = transferOp.account
                currentPickerRowForAccount = presenter.accounts.firstIndex(of: transferOp.account) ?? 0
                currentPickerRowForSpecialField = presenter.accounts.firstIndex(of: transferOp.destinationAccount) ?? 0
            default: return
            }
            
            let valueString = operation.value.currencyFormattedDescription(.rub).filter { "0123456789".contains($0) }
            valueTextField.text = valueString
            dateTextField.text = operation.date.formattedDescription
            datePicker.date = operation.date
            currencySignButton.setTitle(operation.currency.rawValue, for: .normal)
        }
    }
    
    private func operationTypeChanged(from lastType: OperationType, to newType: OperationType) {
        guard lastType != newType else { return }
        var segmentedControlColor: UIColor
        switch (lastType, newType) {
            
        // Case when only flowOp's sign changed
        case let (.flow, .flow(newSign)):
            segmentedControlColor = newSign == .positive ?
                Constants.operationTypeColors.income :
                Constants.operationTypeColors.outcome
            
            currentPickerRowForSpecialField = 0
            let specialValue = (newSign == .positive ? presenter.incomeCategories : presenter.outcomeCategories).first
            specialFieldTextField.text = specialValue
        
            
        // Switched to flowOp
        case let (_, .flow(sign)):
            segmentedControlColor = sign == .positive ?
                Constants.operationTypeColors.income :
                Constants.operationTypeColors.outcome
            
            debtDirectionSegmentedControl.isHidden = true
            valueSignButton.superview!.isHidden = false
            commentTextField.superview!.isHidden = false
            commentLabel.isHidden = false
            valueSignButton.setTitle((sign == .positive ? "+" : "-"), for: .normal)
            currentPickerRowForSpecialField = 0
            specialFieldLabel.text = Constants.titles.category
            
            let specialValue = (sign == .positive ? presenter.incomeCategories : presenter.outcomeCategories).first
            specialFieldTextField.text = specialValue
            if lastType == .debt {
                currentPickerRowForAccount = max(0, currentPickerRowForAccount - 1)
                accountTextField.text = presenter.accounts[currentPickerRowForAccount]
            }
            
            
        // Switched to debtOp
        case (_, .debt):
            segmentedControlColor = Constants.operationTypeColors.debt
            debtDirectionSegmentedControl.isHidden = false
            valueSignButton.superview!.isHidden = true
            commentTextField.superview!.isHidden = false
            commentLabel.isHidden = false
            currentPickerRowForSpecialField = 0
            specialFieldLabel.text = Constants.titles.contact
            specialFieldTextField.text = presenter.contacts.first
            accountTextField.text = presenter.accounts[currentPickerRowForAccount]
            currentPickerRowForAccount += 1
            
            
        // Switched to transferOp
        case (_, .transfer):
            segmentedControlColor = Constants.operationTypeColors.transfer
            debtDirectionSegmentedControl.isHidden = true
            valueSignButton.superview!.isHidden = true
            commentTextField.superview!.isHidden = true
            commentLabel.isHidden = true
            currentPickerRowForSpecialField = 0
            specialFieldLabel.text = Constants.titles.toAccount
            specialFieldTextField.text = presenter.accounts.first
            if lastType == .debt {
                currentPickerRowForAccount = max(0, currentPickerRowForAccount - 1)
                accountTextField.text = presenter.accounts[currentPickerRowForAccount]
            }
        }
        
        if #available(iOS 13.0, *) {
            operationTypeSegmentedControl.selectedSegmentTintColor = segmentedControlColor
        }
        addInputAccessoryForTextFields()
        if specialFieldTextField.isFirstResponder {
            pickerView.reloadAllComponents()
            pickerView.selectRow(0, inComponent: 0, animated: true)
        }
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
            valueTextField.text! = valueTextField.text!.filter { "0123456789.".contains($0) }
        }
        if accountTextField.isFirstResponder {
            pickerView.selectRow(currentPickerRowForAccount, inComponent: 0, animated: false)
            offsetFields(by: 0)
        }
        if specialFieldTextField.isFirstResponder {
            pickerView.selectRow(currentPickerRowForSpecialField, inComponent: 0, animated: false)
            offsetFields(by: Constants.offsetingViews.offsetForCategoryField)
        }
        if dateTextField.isFirstResponder  {
            offsetFields(by: Constants.offsetingViews.offsetForDateField)
        }
        if commentTextField.isFirstResponder {
            offsetFields(by: Constants.offsetingViews.offsetForCommentField)
        }
    }
    
    private func offsetFields(by offset: CGFloat) {
        let currentOffset = bottomViewTopSafeAreaConstraint.constant
        var duration = Double(abs(offset - currentOffset) / Constants.offsetingViews.speed)
        duration = max(duration, Constants.offsetingViews.minimumDuration)
        UIView.animate(withDuration: duration) {
            self.bottomViewTopSafeAreaConstraint.constant = offset
            self.view.layoutIfNeeded()
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if !(valueTextField.text?.isEmpty ?? true) {
            valueTextField.superview!.layer.borderWidth = 0.0
            if let value = Double(valueTextField.text!) {
                var string = value.currencyFormattedDescription(Currency.rub)
                string.removeLast(2)
                valueTextField.text! = string
            }
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
        let date = datePicker.date
        
        var sign: String
        switch operationType {
        case .flow: sign = valueSignButton.titleLabel?.text ?? "+"
        case .debt: sign = debtDirectionSegmentedControl.selectedSegmentIndex == 0 ? "-" : "+"
        case .transfer: sign = "+"
        }
        let valueSign = (sign == "+") ? 1.0 : -1.0
        
        let stringValue = (valueTextField.text ?? "").filter { "0123456789.".contains($0) }
        let value = (Double(stringValue) ?? 0.0) * valueSign
        let currency = Currency(rawValue: currencySignButton.currentTitle!) ?? presenter.currencies.first!
        let account = accountTextField.text! == Constants.titles.emptyAccount ? "" : accountTextField.text!
        let specialField = specialFieldTextField.text!
        var comment = commentTextField.text
        if comment != nil { if comment!.isEmpty { comment = nil } }
        
        if let operation = operationToBeEditted {
            if let flowOp = operation as? FlowOperation {
                flowOp.date = date
                flowOp.value = value
                flowOp.currency = currency
                flowOp.category = specialField
                flowOp.account = account
                flowOp.comment = comment
            } else if let debtOp = operation as? DebtOperation {
                debtOp.date = date
                debtOp.value = value
                debtOp.currency = currency
                debtOp.contact = specialField
                debtOp.account = account
                debtOp.comment = comment
            } else if let transferOp = operation as? TransferOperation {
                transferOp.date = date
                transferOp.value = value
                transferOp.currency = currency
                transferOp.account = account
                transferOp.destinationAccount = specialField
            }
            delegate?.edittedOperation(operation)
        } else {
            var operation: Operation
            switch operationType {
            case .flow: operation = FlowOperation(date: date, value: value, currency: currency, category: specialField, account: account, comment: comment)
            case .debt: operation = DebtOperation(date: date, value: value, currency: currency, contact: specialField, account: account, comment: comment)
            case .transfer: operation = TransferOperation(date: date, value: value, currency: currency, fromAccount: account, toAccount: specialField)
            }
            print(operation)
            delegate?.addedOperation(operation)
        }
        dismiss()
    }
    
    private func dismiss() {
        view.endEditing(true)
        self.dismiss(animated: true)
    }
    
}

extension AddOperationViewController {
    struct Constants {
        struct operationTypeColors {
            static let income = #colorLiteral(red: 0.7333333333, green: 0.8352941176, blue: 0.6705882353, alpha: 1)
            static let outcome = #colorLiteral(red: 0.9568627451, green: 0.6941176471, blue: 0.5137254902, alpha: 1)
            static let debt = #colorLiteral(red: 0.4, green: 0.462745098, blue: 0.9529411765, alpha: 1)
            static let transfer = #colorLiteral(red: 0.1490196078, green: 0.1490196078, blue: 0.1490196078, alpha: 1)
        }
        struct titles {
            static let category = "Категория"
            static let contact = "Контакт"
            static let data = "Дата"
            static let value = "Значение"
            static let account = "Счет"
            static let toAccount = "Cчет зачисления"
            static let comment = "Комментарий"
            static let emptyAccount = "Без счета"
            static let debtGive = "Выдал"
            static let debtGet = "Принял"
            static let debtWillGive = "Отдам"
            static let debtWillGet = "Получу"
            static let pickerViewTitlePlaceHolder = "Empty"
        }
        struct offsetingViews {
            static let speed: CGFloat = 250 / 0.4
            static let minimumDuration = 0.3
            static let returnToOriginStateDuration = 0.2
            static let offsetForCategoryField: CGFloat = -100
            static let offsetForDateField: CGFloat = -200
            static let offsetForCommentField: CGFloat = -250
        }
        static let pickerHeight: CGFloat = 226
        static let becomeFirstResponderDelay: TimeInterval = 0.4
        static let operationTypeAnimationTransitionDuration: TimeInterval = 0.45
        static let localeIdentifier = "ru_RU"
    }
    
    enum OperationType {
        enum Sign { case positive, negative }
        case flow(sign: Sign), debt, transfer
        var sign: Sign? {
            switch self {
            case .flow(let sign): return sign
            case .debt: return nil
            case .transfer: return nil
            }
        }
        
        static func ==(lhs: OperationType, rhs: OperationType) -> Bool {
            switch (lhs, rhs) {
            case let (.flow(a), .flow(b)): return a == b
            case (.debt, .debt): return true
            case (.transfer, .transfer): return true
            default: return false
            }
        }
        static func !=(lhs: OperationType, rhs: OperationType) -> Bool {
            return !(lhs == rhs)
        }
        
    }
}


