//
//  EmptyViewController.swift
//  MoneyFlow
//
//  Created by Никита Гончаров on 07/10/2019.
//  Copyright © 2019 Никита Гончаров. All rights reserved.
//

import UIKit
import FirebaseAuth

class AuthViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let tabBarsegueIdentifier = "tabBarSegue"
    let emailVerifySegueIdentifier = "emailVerifySegue"
    var isSingingUp = true
    
    
    @IBAction func nextButtonTouched(_ sender: UIButton) {
        if let validData = validData() {
            if isSingingUp {
                signUp(email: validData.email, password: validData.password)
            }  else {
                signIn(email: validData.email, password: validData.password)
            }
        }
    }
    
    private func validData() -> (email: String, password: String)? {
        errorLabel.isHidden = true
        emailTextField.superview!.layer.borderWidth = 0.0
        passwordTextField.superview!.layer.borderWidth = 0.0
        
        var validEmail: String? = nil
        var validPass: String? = nil
        
        if let email = emailTextField.text, email.isValidEmail() {
            emailTextField.superview!.layer.borderWidth = 0.0
            errorLabel.isHidden = true
            validEmail = email
        } else {
            errorLabel.text = "Incorrect e-mail"
            if let email = emailTextField.text {
                if email.isEmpty { errorLabel.text = "Fill in the field(s)" }
            }
            errorLabel.isHidden = false
            emailTextField.superview!.layer.borderWidth = 1.0
            emailTextField.superview!.layer.borderColor = #colorLiteral(red: 0.9333333333, green: 0.4078431373, blue: 0.4509803922, alpha: 1)
            emailTextField.becomeFirstResponder()
        }
        
        if let password = passwordTextField.text, !password.isEmpty {
            validPass = password
        } else {
            passwordTextField.superview!.layer.borderWidth = 1.0
            passwordTextField.superview!.layer.borderColor = #colorLiteral(red: 0.9333333333, green: 0.4078431373, blue: 0.4509803922, alpha: 1)
            if errorLabel.isHidden {
                errorLabel.text = "Fill in the field"
                errorLabel.isHidden = false
            }
        }
        
        if let email = validEmail, let password = validPass {
            return (email, password)
        } else {
            return nil
        }
    }
    
    private func signIn(email: String, password: String) {
        startLoading()
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            guard let strongSelf = self else { return }
            self!.stopLoading()
            guard error == nil else {
                self!.errorLabel.text = error!.localizedDescription
                self!.errorLabel.isHidden = false
                return
            }
            if let result = authResult {
                print("ID: \(result.user.uid)")
                print("Email: \(result.user.email)")
                print("Verified: \(result.user.isEmailVerified)")
                if !result.user.isEmailVerified { self!.verifyEmail(for: result.user) }
                else { self!.performSegue(withIdentifier: self!.tabBarsegueIdentifier, sender: nil) }
            }
            
        }
    }
    
    private func signUp(email: String, password: String) {
        startLoading()
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            guard let strongSelf = self else { return }
            self!.stopLoading()
            guard error == nil else {
                self!.errorLabel.text = error!.localizedDescription
                self!.errorLabel.isHidden = false
                return
            }
            if let result = authResult {
                print("ID: \(result.user.uid)")
                print("Email: \(result.user.email)")
                print("Verified: \(result.user.isEmailVerified)")
                if !result.user.isEmailVerified { self!.verifyEmail(for: result.user) }
            }
            
        }
    }
    
    private func verifyEmail(for user: User) {
        if !user.isEmailVerified {
            startLoading()
            user.sendEmailVerification { [weak self] error in
                guard let strongSelf = self else { return }
                self!.stopLoading()
                if let error = error {
                    self!.errorLabel.text = "Error: \(error.localizedDescription)"
                    self!.errorLabel.isHidden = false
                } else {
                    self!.performSegue(withIdentifier: self!.emailVerifySegueIdentifier, sender: user)
                }
            }
        }
    }
    
    private func startLoading() {
        nextButton.isHidden = true
        activityIndicator.startAnimating()
    }
    private func stopLoading() {
        activityIndicator.stopAnimating()
        nextButton.isHidden = false
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Auth.auth().languageCode = "ru"
        emailTextField.becomeFirstResponder()
        if isSingingUp {
            titleLabel.text = "Регистрация"
        } else {
            titleLabel.text = "Авторизация"
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let verifyVC = segue.destination as? VerifyEmailViewController {
            if let user = sender as? User {
                verifyVC.user = user
            }
        }
        if let tabBarVC = segue.destination as? UITabBarController {
            tabBarVC.selectedIndex = 1
        }
    }

}

extension String {
    func isValidEmail() -> Bool {
        // here, `try!` will always succeed because the pattern is valid
        let pattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}$"
        let regex = try! NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        return regex.firstMatch(in: self, options: [], range: NSRange(location: 0, length: count)) != nil
    }
}
