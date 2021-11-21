//
//  EditTableViewCell.swift
//  romanova
//
//  Created by Roman Fedotov on 07.11.2021.
//

import UIKit
import FirebaseFirestore

class EditTableViewCell: UITableViewCell {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    
    // MARK: - Properties
    
    let db = Firestore.firestore()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let date = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        timeLabel.isHidden = true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
}
