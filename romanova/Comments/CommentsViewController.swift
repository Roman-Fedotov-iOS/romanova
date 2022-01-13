//
//  CommentsViewController.swift
//  romanova
//
//  Created by Roman Fedotov on 07.11.2021.
//

import UIKit
import FirebaseFirestore
import IQKeyboardManagerSwift

class CommentsViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var grayView: UIView!
    @IBOutlet weak var blackView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var commentTableView: UITableView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var bottonViewBottomConstraint: NSLayoutConstraint!
    
    // MARK: - Properties
    
    var arr = [String]()
    let db = Firestore.firestore()
    var podcasts: [PodcastModel] = []
    var podcastModel: PodcastModel? = nil
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLabelTap()
        self.commentTableView.estimatedRowHeight = 250
        self.commentTableView.rowHeight = UITableView.automaticDimension
        commentTextField.delegate = self
        titleLabel.text = NSLocalizedString("screen.comments.title", comment: "")
        titleLabel.font = .rounded(ofSize: 18, weight: .bold)
        sendButton.setTitle(NSLocalizedString("screen.comments.send_button.text", comment: ""), for: .normal)
        commentTextField.placeholder = NSLocalizedString("screen.comments.text_field_placeholder.text", comment: "")
        db.collection("comments")
            .whereField("podcastId", isEqualTo: podcastModel?.id)
            .getDocuments() { (snapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in snapshot!.documents {
                        if var txt = self.commentTextField.text {
                            txt = document.get("comment") as! String
                            self.arr.insert(txt, at: 0)
                            self.commentTableView.beginUpdates()
                            self.commentTableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .right)
                            self.commentTableView.endUpdates()
                        }
                    }
                }
            }
        
        IQKeyboardManager.shared.enable = false
        //Subscribe to a Notification which will fire before the keyboard will show
        subscribeToNotification(UIResponder.keyboardWillShowNotification, selector: #selector(keyboardWillShowOrHide))
        
        //Subscribe to a Notification which will fire before the keyboard will hide
        subscribeToNotification(UIResponder.keyboardWillHideNotification, selector: #selector(keyboardWillShowOrHide))
    }
    
    deinit {
        unsubscribeFromAllNotifications()

    }
    
    // MARK: - IBActions
    
    @IBAction func backButtonAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func sendButtonAction(_ sender: UIButton) {
        if let txt = commentTextField.text, !txt.isEmpty {
            self.arr.insert(txt, at: 0)
            commentTableView.beginUpdates()
            commentTableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .right)
            commentTableView.endUpdates()
            let date = Date()
            let calendar = Calendar.current
            let hour = calendar.component(.hour, from: date)
            let minutes = calendar.component(.minute, from: date)
            db.collection("comments").document("\(Date().millisecondsSince1970)").setData([
                "userId": UserDefaults.standard.string(forKey: "email"),
                "podcastId": podcastModel?.id,
                "comment": txt,
                "time": "\(String(hour))" + ":" + "\(String(minutes))"
            ]) { err in
                if let err = err {
                    print("Error writing document: \(err)")
                } else {
                }
            }
        }
        commentTextField.text?.removeAll()
        UIApplication.shared.sendAction(#selector(UIApplication.resignFirstResponder), to: nil, from: nil, for: nil);
    }
    
    // MARK: - Funcs
    
    func setupLabelTap() {
        let dismissKeyboardTap = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard(_:)))
        self.view.addGestureRecognizer(dismissKeyboardTap)
    }
    
    @objc func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    func subscribeToNotification(_ notification: NSNotification.Name, selector: Selector) {
        NotificationCenter.default.addObserver(self, selector: selector, name: notification, object: nil)
    }
        
    func unsubscribeFromAllNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
        
    @objc func keyboardWillShowOrHide(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            UIView.animate(withDuration: 0.7, delay: 0.1, options: .curveEaseInOut) { [weak self] in
                self?.bottonViewBottomConstraint.constant = 0.0
            }
        }
        
        if notification.name == UIResponder.keyboardWillShowNotification {
            print(self.view.frame.origin.y)
            UIView.animate(withDuration: 0.7, delay: 0.1, options: .curveEaseIn) { [weak self] in
                self?.bottonViewBottomConstraint.constant = keyboardScreenEndFrame.height
            }
        }
    }
}

// MARK: - Extensions

extension CommentsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arr.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = commentTableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath) as? EditTableViewCell else {return UITableViewCell()}
        cell.commentLabel.text = arr[indexPath.row]
        db.collection("comments")
            .whereField("podcastId", isEqualTo: podcastModel?.id)
            .whereField("comment", isEqualTo: cell.commentLabel.text)
            .getDocuments() { (snapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in snapshot!.documents {
                        let txt = document.get("time") as! String
                        cell.timeLabel.text = txt
                        let txt2 = document.get("userId") as! String
                        cell.nameLabel.text = txt2
                    }
                }
            }
        return cell
    }
}
