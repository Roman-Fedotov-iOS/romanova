//
//  SignUpViewController.swift
//  romanova
//
//  Created by Roman Fedotov on 13.10.2021.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore
import AuthenticationServices
import GoogleSignIn
import CryptoKit

class SignUpViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    
    @IBOutlet weak var emailGrayView: UIView!
    @IBOutlet weak var passwordGrayView: UIView!
    @IBOutlet weak var screenTitle: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var emailFieldBorder: UIImageView!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var passwordFieldBorder: UIImageView!
    @IBOutlet weak var hidePasswordButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var newUserLabel: UILabel!
    @IBOutlet weak var moveToSignInButton: UILabel!
    
    var isPasswordHidden: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLabelTap()
        emailFieldBorder.isHidden = true
        passwordFieldBorder.isHidden = true
        emailField.delegate = self
        passwordField.delegate = self
        screenTitle.font = .rounded(ofSize: 36, weight: .bold)
        screenTitle.text = NSLocalizedString("screen.sign_up.title", comment: "")
        signUpButton.setTitle(NSLocalizedString("screen.sign_up.button.text", comment: ""), for: .normal)
        newUserLabel.font = .rounded(ofSize: 14, weight: .regular)
        newUserLabel.text = NSLocalizedString("screen.sign_up.new_user_label", comment: "")
        moveToSignInButton.font = .rounded(ofSize: 14, weight: .medium)
        moveToSignInButton.text = NSLocalizedString("screen.sign_up.sign_in_label", comment: "")
    }
    
    func setupLabelTap() {
        let dismissKeyboardTap = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard(_:)))
        let toSignInTap = UITapGestureRecognizer(target: self, action: #selector(self.toSignInGesture(_:)))
        self.view.addGestureRecognizer(dismissKeyboardTap)
        self.moveToSignInButton.addGestureRecognizer(toSignInTap)
    }
    
    @objc func toSignInGesture(_ sender: UITapGestureRecognizer) {
        if let controller = storyboard?.instantiateViewController(identifier: "SignInVC") as? SignInViewController {
            controller.modalTransitionStyle = .crossDissolve
            controller.modalPresentationStyle = .fullScreen
            present(controller, animated: true, completion: nil)
        }
    }
    
    @objc func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    func showAlert() {
        let alert = UIAlertController(title: NSLocalizedString("case.exception_label", comment: ""), message: NSLocalizedString("case.incorrect_fill_label", comment: ""), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true)
    }
    
    func showPasswordAlert() {
        let alert = UIAlertController(title: NSLocalizedString("case.exception_label", comment: ""), message: NSLocalizedString("case.short_password_label", comment: ""), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true)
    }
    
    // MARK: - IBActions
    
    @IBAction func emailFieldAction(_ sender: UITextField) {
        emailGrayView.isHidden = true
        UIView.transition(with: emailFieldBorder, duration: 0.1,
                          options: .transitionCrossDissolve,
                          animations: {
            self.emailFieldBorder.isHidden = false
                      })
    }
    
    @IBAction func passwordFieldAction(_ sender: UITextField) {
        passwordGrayView.isHidden = true
        UIView.transition(with: passwordFieldBorder, duration: 0.1,
                          options: .transitionCrossDissolve,
                          animations: {
            self.passwordFieldBorder.isHidden = false
                      })
    }
    
    @IBAction func backButtonAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func hidePasswordButtonAction(_ sender: UIButton) {
        if(isPasswordHidden == true) {
            passwordField.isSecureTextEntry = false
        } else {
            passwordField.isSecureTextEntry = true
        }
        isPasswordHidden = !isPasswordHidden
    }
    
    @IBAction func signUpButtonAction(_ sender: UIButton) {
        let email = emailField.text!
        let password = passwordField.text!
        
        if (!email.isEmpty && !password.isEmpty) {
            Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
                if error == nil {
                    if let result = result {
                        image = "exitButton"
                        UserDefaults.standard.set(image, forKey: "image")
                        if let controller = self.storyboard?.instantiateViewController(identifier: "MainVC") as? MainViewController {
                            controller.modalTransitionStyle = .crossDissolve
                            controller.modalPresentationStyle = .fullScreen
                            self.present(controller, animated: true, completion: nil)
                        }
                    }
                } else if error != nil {
                    self.showPasswordAlert()
                }
            }
        } else {
            showAlert()
        }
    }
}

// MARK: - Extensions

extension SignUpViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let email = emailField.text!
        let password = passwordField.text!
        
        if (!email.isEmpty && !password.isEmpty) {
            Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
                if error == nil {
                    if let result = result {
                        image = "exitButton"
                        UserDefaults.standard.set(image, forKey: "image")
                        if let controller = self.storyboard?.instantiateViewController(identifier: "MainVC") as? MainViewController {
                            controller.modalTransitionStyle = .crossDissolve
                            controller.modalPresentationStyle = .fullScreen
                            self.present(controller, animated: true, completion: nil)
                        }
                    }
                }
            }
        } else {
            showAlert()
        }
        self.view.endEditing(true)
        return false
    }
}
