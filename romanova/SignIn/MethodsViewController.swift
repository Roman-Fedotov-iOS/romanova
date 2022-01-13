//
//  MethodsViewController.swift
//  romanova
//
//  Created by Roman Fedotov on 19.10.2021.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore
import AuthenticationServices
import GoogleSignIn
import CryptoKit

// MARK: - Properties

var image: String = "exitButton"

var authMethod: String? = ""

class MethodsViewController: UIViewController, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var screenTitle: UILabel!
    @IBOutlet weak var appleButton: ASAuthorizationAppleIDButton!
    @IBOutlet weak var appleButtonLabel: UILabel!
    @IBOutlet weak var googleButton: GIDSignInButton!
    @IBOutlet weak var googleButtonLabel: UILabel!
    @IBOutlet weak var emailButton: UIButton!
    @IBOutlet weak var emailButtonLabel: UILabel!
    @IBOutlet weak var newUserLabel: UILabel!
    @IBOutlet weak var moveToSignUpLabel: UILabel!
    @IBOutlet weak var forgotPasswordLabel: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        showAlert()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLabelTap()
        appleButton.addTarget(self, action: #selector(startSignInWithAppleFlow), for: .touchUpInside)
        screenTitle.font = .rounded(ofSize: 36, weight: .bold)
        screenTitle.text = NSLocalizedString("screen.methods.title", comment: "")
        appleButtonLabel.font = .rounded(ofSize: 14, weight: .bold)
        appleButtonLabel.text = NSLocalizedString("screen.methods.apple_button.text", comment: "")
        googleButtonLabel.font = .rounded(ofSize: 14, weight: .bold)
        googleButtonLabel.text = NSLocalizedString("screen.methods.google_button.text", comment: "")
        emailButtonLabel.font = .rounded(ofSize: 14, weight: .bold)
        emailButtonLabel.text = NSLocalizedString("screen.methods.email_button.text", comment: "")
        newUserLabel.font = .rounded(ofSize: 14, weight: .regular)
        newUserLabel.text = NSLocalizedString("screen.methods.new_user_label", comment: "")
        moveToSignUpLabel.font = .rounded(ofSize: 14, weight: .medium)
        moveToSignUpLabel.text = NSLocalizedString("screen.methods.sign_up_label", comment: "")
        forgotPasswordLabel.font = .rounded(ofSize: 14, weight: .medium)
        forgotPasswordLabel.text = NSLocalizedString("screen.methods.skip_label", comment: "")
    }
    
    // MARK: - Funcs
    
    func setupLabelTap() {
        let toSignUpTap = UITapGestureRecognizer(target: self, action: #selector(self.toSignUpGesture(_:)))
        let toForgotTap = UITapGestureRecognizer(target: self, action: #selector(self.SignInAnonymous(_:)))
        self.moveToSignUpLabel.addGestureRecognizer(toSignUpTap)
        self.forgotPasswordLabel.addGestureRecognizer(toForgotTap)
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
    
    @objc func toSignUpGesture(_ sender: UITapGestureRecognizer) {
        if let controller = storyboard?.instantiateViewController(identifier: "SignUpVC") as? SignUpViewController {
            controller.modalTransitionStyle = .crossDissolve
            controller.modalPresentationStyle = .fullScreen
            present(controller, animated: true, completion: nil)
        }
    }
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: Array<Character> =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }
    
    fileprivate var currentNonce: String?
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                      idToken: idTokenString,
                                                      rawNonce: nonce)
            Auth.auth().signIn(with: credential) { (authResult, error) in
                if (error != nil) {
                    // Error. If error.code == .MissingOrInvalidNonce, make sure
                    // you're sending the SHA256-hashed nonce as a hex string with
                    // your request to Apple.
                    print(error?.localizedDescription ?? "")
                    return
                }
                image = "exitButton"
                UserDefaults.standard.set(image, forKey: "image")
                authMethod = "apple"
                UserDefaults.standard.set(authMethod, forKey: "authMethod")
                UserDefaults.standard.set(authResult?.user.uid, forKey: "idToken")
                if let controller = self.storyboard?.instantiateViewController(identifier: "MainVC") as? MainViewController {
                    controller.modalTransitionStyle = .crossDissolve
                    controller.modalPresentationStyle = .fullScreen
                    self.present(controller, animated: true, completion: nil)
                }
                guard let user = authResult?.user else { return }
                let email = user.email ?? ""
                let displayName = user.displayName ?? ""
                guard let uid = Auth.auth().currentUser?.uid else { return }
                UserDefaults.standard.set(email, forKey: "email")
                let db = Firestore.firestore()
                db.collection("User").document(uid).setData([
                    "email": email,
                    "displayName": displayName,
                    "uid": uid
                ]) { err in
                    if let err = err {
                        print("Error writing document: \(err)")
                    } else {
                        print("the user has sign up or is logged in")
                    }
                }
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
        print("Sign in with Apple errored: \(error)")
    }
    
    @available(iOS 13, *)
    @objc func startSignInWithAppleFlow() {
        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    @available(iOS 13, *)
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            return String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
    
    func showAlert() {
        if !isInternetAvailable() {
            let alert = UIAlertController(title: NSLocalizedString("case.exception_label", comment: ""), message: NSLocalizedString("screen.main.alert.description", comment: ""), preferredStyle: .alert)
            let action = UIAlertAction(title: NSLocalizedString("screen.main.alert.text.button", comment: ""), style: .default, handler: { action in
                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                    return
                }
                
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                        print("Settings opened: \(success)") // Prints true
                    })
                }
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
    
    // MARK: - IBActions
    
    @IBAction func appleButtonAction(_ sender: ASAuthorizationAppleIDButton) {
    }
    
    @IBAction func googleButtonAction(_ sender: GIDSignInButton) {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        let config = GIDConfiguration(clientID: clientID)
        
        GIDSignIn.sharedInstance.signIn(with: config, presenting: self) { [unowned self] user, error in
            
            if let error = error {
                return
            }
            
            guard
                let authentication = user?.authentication,
                let idToken = authentication.idToken
            else {
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: authentication.accessToken)
            
            Auth.auth().signIn(with: credential) { authResult, error in
                image = "exitButton"
                UserDefaults.standard.set(image, forKey: "image")
                authMethod = "google"
                UserDefaults.standard.set(authResult?.user.email, forKey: "email")
                UserDefaults.standard.set(authMethod, forKey: "authMethod")
                UserDefaults.standard.set(authResult?.user.uid, forKey: "idToken")
                if let controller = self.storyboard?.instantiateViewController(identifier: "MainVC") as? MainViewController {
                    controller.modalTransitionStyle = .crossDissolve
                    controller.modalPresentationStyle = .fullScreen
                    self.present(controller, animated: true, completion: nil)
                }
                return
            }
        }
    }
    @IBAction func emailButtonAction(_ sender: UIButton) {
        if let controller = storyboard?.instantiateViewController(identifier: "SignInVC") as? SignInViewController {
            controller.modalTransitionStyle = .crossDissolve
            controller.modalPresentationStyle = .fullScreen
            present(controller, animated: true, completion: nil)
        }
    }
}
