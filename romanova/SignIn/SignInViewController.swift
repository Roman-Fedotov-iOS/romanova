//
//  SignInViewController.swift
//  romanova
//
//  Created by Roman Fedotov on 13.10.2021.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore

class SignInViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var hidePasswordButton: UIButton!
    @IBOutlet weak var emailGrayView: UIView!
    @IBOutlet weak var passwordGrayView: UIView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var screenTitle: UILabel!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var emailFieldBorder: UIImageView!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var passwordFieldBorder: UIImageView!
    @IBOutlet weak var forgotPasswordLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var newUserLabel: UILabel!
    @IBOutlet weak var moveToSignUpButton: UILabel!
    @IBOutlet weak var skipButton: UILabel!
    
    var isPasswordHidden: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        passwordField.isSecureTextEntry = true
        emailFieldBorder.isHidden = true
        passwordFieldBorder.isHidden = true
        createSpinnerView()
        showInternetAlert()
        setupLabelTap()
        emailField.delegate = self
        passwordField.delegate = self
        screenTitle.font = .rounded(ofSize: 36, weight: .bold)
        screenTitle.text = NSLocalizedString("screen.sign_in.title", comment: "")
        forgotPasswordLabel.font = .rounded(ofSize: 14, weight: .medium)
        forgotPasswordLabel.text = NSLocalizedString("screen.sign_in.password_view.forgot_label.text", comment: "")
        loginButton.setTitle(NSLocalizedString("screen.sign_in.button.text", comment: ""), for: .normal)
        newUserLabel.font = .rounded(ofSize: 14, weight: .regular)
        newUserLabel.text = NSLocalizedString("screen.sign_in.new_user_label", comment: "")
        moveToSignUpButton.font = .rounded(ofSize: 14, weight: .medium)
        moveToSignUpButton.text = NSLocalizedString("screen.sign_in.sign_up_label", comment: "")
        skipButton.font = .rounded(ofSize: 14, weight: .medium)
        skipButton.text = NSLocalizedString("screen.sign_in.skip_label", comment: "")
    }
    
    // MARK: - Funcs
    
    func showAlert() {
        let alert = UIAlertController(title: NSLocalizedString("case.exception_label", comment: ""), message: NSLocalizedString("case.incorrect_fill_label", comment: ""), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true)
    }
    
    func showPasswordAlert() {
        let alert = UIAlertController(title: NSLocalizedString("case.exception_label", comment: ""), message: NSLocalizedString("case.incorrect_password_label", comment: ""), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true)
    }
    
    func createSpinnerView() {
        let child = SpinnerViewController()
        
        addChild(child)
        child.view.frame = view.frame
        view.addSubview(child.view)
        child.didMove(toParent: self)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            child.willMove(toParent: nil)
            child.view.removeFromSuperview()
            child.removeFromParent()
        }
    }
    
    func showInternetAlert() {
        if !isInternetAvailable() {
            let alert = UIAlertController(title: NSLocalizedString("case.exception_label", comment: ""), message: NSLocalizedString("screen.main.alert.description", comment: ""), preferredStyle: .alert)
            let action = UIAlertAction(title: NSLocalizedString("screen.main.alert.text.button", comment: ""), style: .default, handler: { action in
                exit(0)
            })
            alert.addAction(action)
            let screenSize: CGRect = UIScreen.main.bounds
            let screenWidth = screenSize.width
            let screenHeight = screenSize.height
            let layer = CALayer()
            layer.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
            layer.backgroundColor = UIColor.white.cgColor
            view.layer.addSublayer(layer)
            present(alert, animated: true, completion: nil)
        }
    }
    
    func setupLabelTap() {
        let toSignUpTap = UITapGestureRecognizer(target: self, action: #selector(self.toSignUpGesture(_:)))
        let toForgotTap = UITapGestureRecognizer(target: self, action: #selector(self.toForgotGesture(_:)))
        let signInAnonymousTap = UITapGestureRecognizer(target: self, action: #selector(self.SignInAnonymous(_:)))
        let dismissKeyboardTap = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard(_:)))
        self.moveToSignUpButton.addGestureRecognizer(toSignUpTap)
        self.forgotPasswordLabel.addGestureRecognizer(toForgotTap)
        self.skipButton.addGestureRecognizer(signInAnonymousTap)
        self.view.addGestureRecognizer(dismissKeyboardTap)
    }
    
    @objc func toSignUpGesture(_ sender: UITapGestureRecognizer) {
        if let controller = storyboard?.instantiateViewController(identifier: "SignUpVC") as? SignUpViewController {
            controller.modalTransitionStyle = .crossDissolve
            controller.modalPresentationStyle = .fullScreen
            present(controller, animated: true, completion: nil)
        }
    }
    
    @objc func toForgotGesture(_ sender: UITapGestureRecognizer) {
        if let controller = storyboard?.instantiateViewController(identifier: "Forgot1VC") as? ForgotPasswordEmailViewController {
            controller.modalTransitionStyle = .crossDissolve
            controller.modalPresentationStyle = .fullScreen
            present(controller, animated: true, completion: nil)
        }
    }
    
    @objc func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    @objc func SignInAnonymous(_ sender: UITapGestureRecognizer) {
        Auth.auth().signInAnonymously { (authResult, error) in
            if (authResult?.user) != nil {
                image = "loginButton"
                UserDefaults.standard.set(image, forKey: "image")
                authMethod = nil
                UserDefaults.standard.set(authMethod, forKey: "authMethod")
                let controller = self.storyboard?.instantiateViewController(identifier: "MainVC") as? MainViewController
                controller?.modalTransitionStyle = .crossDissolve
                controller?.modalPresentationStyle = .fullScreen
                self.present(controller!, animated: true, completion: nil)
                return
            } else {
                print(error as Any)
            }
        }
    }
    
    // MARK: - IBActions
    
    @IBAction func hidePasswordButtonAction(_ sender: UIButton) {
        isPasswordHidden = !isPasswordHidden
        if passwordField.isSecureTextEntry == true {
            hidePasswordButton.setImage(UIImage(named: "seenPassword"), for: .normal)
            passwordField.isSecureTextEntry = false
        } else if isPasswordHidden == false {
            hidePasswordButton.setImage(UIImage(named: "hiddenPassword"), for: .normal)
            passwordField.isSecureTextEntry = true
        }
    }
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
        if let controller = storyboard?.instantiateViewController(identifier: "MethodsVC") as? MethodsViewController {
            controller.modalTransitionStyle = .crossDissolve
            controller.modalPresentationStyle = .fullScreen
            present(controller, animated: true, completion: nil)
        }
    }
    
    @IBAction func loginButtonAction(_ sender: UIButton) {
        let email = emailField.text!
        let password = passwordField.text!
        
        if (!email.isEmpty && !password.isEmpty) {
            Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
                if error == nil {
                    if let result = result {
                        image = "exitButton"
                        UserDefaults.standard.set(image, forKey: "image")
                        authMethod = "email"
                        UserDefaults.standard.set(result.user.email, forKey: "email")
                        UserDefaults.standard.set(authMethod, forKey: "authMethod")
                        UserDefaults.standard.set(result.user.uid, forKey: "idToken")
                        if let controller = self.storyboard?.instantiateViewController(identifier: "MainVC") as? MainViewController {
                            controller.modalTransitionStyle = .crossDissolve
                            controller.modalPresentationStyle = .fullScreen
                            self.present(controller, animated: true, completion: nil)
                        }
                    }
                }
                else if error != nil {
                    self.showPasswordAlert()
                }
            }
        } else {
            showAlert()
        }
    }
}

// MARK: - Extensions

extension SignInViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let email = emailField.text!
        let password = passwordField.text!
        
        if (!email.isEmpty && !password.isEmpty) {
            Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
                if error == nil {
                    if let result = result {
                        image = "exitButton"
                        UserDefaults.standard.set(image, forKey: "image")
                        authMethod = "email"
                        UserDefaults.standard.set(result.user.email, forKey: "email")
                        UserDefaults.standard.set(authMethod, forKey: "authMethod")
                        UserDefaults.standard.set(result.user.uid, forKey: "idToken")
                        if let controller = self.storyboard?.instantiateViewController(identifier: "MainVC") as? MainViewController {
                            controller.modalTransitionStyle = .crossDissolve
                            controller.modalPresentationStyle = .fullScreen
                            self.present(controller, animated: true, completion: nil)
                        }
                    }
                }
                else if error != nil {
                    self.showPasswordAlert()
                }
            }
        } else {
            showAlert()
        }
        self.view.endEditing(true)
        return false
    }
}
