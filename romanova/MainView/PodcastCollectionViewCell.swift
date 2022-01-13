//
//  PodcastCollectionViewCell.swift
//  romanova
//
//  Created by Roman Fedotov on 25.08.2021.
//

import UIKit
import Kingfisher
import FirebaseFirestore

class PodcastCollectionViewCell: UICollectionViewCell {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var likeCountLabel: UILabel!
    @IBOutlet weak var commentsCountLabel: UILabel!
    @IBOutlet weak var podcastImage: UIImageView!
    @IBOutlet weak var podcastTitle: UILabel!
    @IBOutlet weak var podcastDuration: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    
    // MARK: - Properties
    
    static let identifier = String(describing: PodcastCollectionViewCell.self)
    var commentClick: () -> () = { }
    
    // MARK: - Funcs
    
    func setup(podcast: PodcastModel, onCellClick: @escaping (Int64) -> (), onCommentsClick: @escaping (Int64) -> (), onLikeClick: @escaping (Int64) -> ()) {
        podcastTitle.text = podcast.title
        podcastTitle.font = .rounded(ofSize: 16, weight: .bold)
        podcastDuration.text = createDuration(ms: podcast.duration).toString(isTimeInverted: isTimeInverted)
        podcastDuration.font = .rounded(ofSize: 16, weight: .regular)
        let processor = RoundCornerImageProcessor(cornerRadius: 40)
        podcastImage.kf.setImage(with: podcast.largeArtworkUrl!.asURL, options: [.processor(processor)])
        let tap = TrackTapGesture(target: self, action: #selector(self.onCellClick))
        let tap2 = CommentsTapGesture(target: self, action: #selector(self.onCommentsClick))
        let tap3 = LikeTapGesture(target: self, action: #selector(self.onLikeClick))
        tap2.onClick = onCommentsClick
        tap2.podcastId = podcast.id
        tap.podcastId = podcast.id
        tap.onClick = onCellClick
        tap3.onClick = onLikeClick
        tap3.podcastId = podcast.id
        podcastImage.addGestureRecognizer(tap)
        commentButton.addGestureRecognizer(tap2)
        likeButton.addGestureRecognizer(tap3)
        podcastImage.isUserInteractionEnabled = true
    }
    
    @objc func onCellClick(tapGesture: TrackTapGesture) {
        tapGesture.onClick(tapGesture.podcastId)
    }
    
    @objc func onCommentsClick(tapGesture: CommentsTapGesture) {
        tapGesture.onClick(tapGesture.podcastId)
    }
    
    @objc func onLikeClick(tapGesture: LikeTapGesture) {
        tapGesture.onClick(tapGesture.podcastId)
    }
    
    
    func createDuration(ms: UInt) -> Duration {
        Duration(seconds: (ms/1000)%60, minutes: (ms/(1000*60))%60, hours: (ms/(1000*60*60)))
    }
    
    // MARK: - Classes
    
    class TrackTapGesture: UITapGestureRecognizer {
        var podcastId: Int64 = 0
        var onClick: (Int64) -> () = {_ in }
    }
    
    class CommentsTapGesture: UITapGestureRecognizer {
        var podcastId: Int64 = 0
        var onClick: (Int64) -> () = {_ in }
    }
    
    class LikeTapGesture: UITapGestureRecognizer {
        var podcastId: Int64 = 0
        var onClick: (Int64) -> () = {_ in }
    }
    
    // MARK: - IBActions
    
    @IBAction func likeButtonAction(_ sender: UIButton) {
    }
    
    @IBAction func commentButtonAction(_ sender: UIButton, storyboard: UIStoryboard) {
    }
}
