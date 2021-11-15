//
//  CommentsViewController.swift
//  romanova
//
//  Created by Roman Fedotov on 07.11.2021.
//

import UIKit
import FirebaseFirestore

class CommentsViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var commentTableView: UITableView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var backButton: UIButton!
    
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
                "userId": UserDefaults.standard.string(forKey: "idToken"),
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
    }
    
    func setupLabelTap() {
        let dismissKeyboardTap = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard(_:)))
        self.view.addGestureRecognizer(dismissKeyboardTap)
    }
    
    @objc func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
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
