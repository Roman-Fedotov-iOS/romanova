//
//  MainViewController.swift
//  OnBoardingScreen
//
//  Created by Roman Fedotov on 25.08.2021.
//

import UIKit
import AVKit
import Kingfisher
import FirebaseFirestore

class MainViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var podcastCollectionView: UICollectionView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var buttonToAbout: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var podcastImage: UIImageView!
    @IBOutlet weak var podcastTitle: UILabel!
    @IBOutlet weak var podcastBottomView: UIView!
    @IBOutlet weak var nowListeningLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var jobLabel: UILabel!
    
    // MARK: - Properties
    
    var podcasts: [PodcastModel] = []
    let networkService = NetworkService()
    let child = SpinnerViewController()
    let db = Firestore.firestore()
    var commentsCount: Int = 0
    var likesCount: Int = 0
    
    override func viewWillAppear(_ animated: Bool) {
        if player?.isPlaying == true {
            playButton.setImage(UIImage(named: "pause"), for: .normal)
        }
        showAlert()
        self.podcastCollectionView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createSpinnerView()
        registerCells()
        fetchPodcasts()
        podcastBottomView.dropShadow()
        podcastTitle.font = .rounded(ofSize: 14, weight: .bold)
        nowListeningLabel.text = NSLocalizedString("screen.main.now_playing.title", comment: "")
        nowListeningLabel.font = .rounded(ofSize: 14, weight: .regular)
        nameLabel.text = NSLocalizedString("screen.main.about_author.text.author_name", comment: "")
        nameLabel.font = .rounded(ofSize: 18, weight: .bold)
        jobLabel.text = NSLocalizedString("screen.main.about_author.text.top_view_title", comment: "")
        jobLabel.font = .rounded(ofSize: 14, weight: .regular)
        
        let gestureToAboutScreen = UITapGestureRecognizer(target: self, action:  #selector(self.toAboutAction(sender:)))
        self.topView.addGestureRecognizer(gestureToAboutScreen)
        
        NotificationCenter.default.addObserver(self, selector: #selector(didGetNotification(_:)), name: Notification.Name("text"), object: nil)
        
        self.podcastBottomView.isHidden = true
        self.nowListeningLabel.isHidden = true
        
        decodeModel()
        initPlayer()
        podcastCollectionView.backgroundColor = UIColor.clear.withAlphaComponent(0)
        podcastCollectionView.register(HeaderCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HeaderCollectionReusableView.identifier)
    }
    
    // MARK: - Funcs
    
    @objc func didGetNotification(_ notification: Notification) {
        let model = notification.object as? PodcastModel?
        if model != nil {
            setupBottomView(model: model!!)
        }
    }
    
    func setupBottomView(model: PodcastModel) {
        self.podcastBottomView.isHidden = false
        self.nowListeningLabel.isHidden = false
        podcastTitle.text = model.title
    }
    
    func decodeModel() {
        if let data = UserDefaults.standard.data(forKey: "currentModel") {
            do {
                let decoder = JSONDecoder()
                
                let currentPodcast = try decoder.decode(PodcastModel.self, from: data)
                setupBottomView(model: currentPodcast)
                currentPodcastModel = currentPodcast
            } catch {
                print("Unable to Decode Note (\(error))")
            }
        }
    }
    
    private func fetchPodcasts(retryCount: Int = 3) {
        let urlString = "https://api-v2.soundcloud.com/users/1025550217/tracks?\(clientId)"
        
        networkService.getTracks(urlString: urlString) { (result) in
            switch result {
            case .success(let trackResponse):
                trackResponse.collection.forEach {
                    self.podcasts.append(PodcastModel(id: $0.id,
                                                      duration: $0.duration ?? 123,
                                                      likeCount: $0.likes_count ?? 1,
                                                      title: $0.title ?? "",
                                                      largeArtworkUrl: $0.large_artwork_url ?? "",
                                                      smallArtworkUrl: $0.small_artwork_url ?? "",
                                                      streamUrl: $0.media?.transcodings.first(where: { transcoding in
                        transcoding.format.protocol == "progressive"
                    })!.url ?? "",
                                                      waveformUrl: $0.waveform_url ?? ""))
                }
                self.podcastCollectionView.reloadData()
            case .failure(let error):
                self.fetchPodcasts(retryCount: retryCount - 1)
                print(error)
            }
        }
    }
    
    private func registerCells() {
        podcastCollectionView.register(UINib(nibName: PodcastCollectionViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: PodcastCollectionViewCell.identifier)
    }
    
    @objc func toAboutAction(sender : UITapGestureRecognizer) {
        if let controller = storyboard?.instantiateViewController(identifier: "AboutVC") as? AboutViewController {
            controller.modalTransitionStyle = .crossDissolve
            controller.modalPresentationStyle = .fullScreen
            present(controller, animated: true, completion: nil)
        }
    }
    
    func initPlayer() {
        if currentPodcastModel != nil {
            let urlStr = "\(currentPodcastModel!.streamUrl)?client_id=\(clientId)"
            
            let streamURLRequest = StreamUrlRequest(completionHandler: { (result) in
                switch result {
                case .success(let streamResponse):
                    do {
                        try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
                        playerItem = AVPlayerItem(url: streamResponse.url.asURL!)
                        player = AVQueuePlayer(playerItem: playerItem)
                        player?.seek(to: CMTimeMake(value: Int64(currentPodcastModel!.currentPlayTime), timescale: 1))
                    } catch {}
                case .failure(let error):
                    self.createSpinnerView()
                }
            }).getStreamUrl(streamUrl: urlStr)
        }
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
    
    @IBAction func buttonToAboutAction(_ sender: UIButton) {
        if let controller = storyboard?.instantiateViewController(identifier: "AboutVC") as? AboutViewController {
            controller.modalTransitionStyle = .crossDissolve
            controller.modalPresentationStyle = .fullScreen
            present(controller, animated: true, completion: nil)
        }
    }
    
    @IBAction func playButtonAction(_ sender: UIButton) {
        if player?.isPlaying == true {
            playButton.setImage(UIImage(named: "play"), for: .normal)
            player?.pause()
        } else {
            playButton.setImage(UIImage(named: "pause"), for: .normal)
            player?.play()
        }
    }
}

// MARK: - Extensions

extension MainViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return podcasts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PodcastCollectionViewCell.identifier, for: indexPath) as! PodcastCollectionViewCell
        cell.setup(podcast: podcasts[indexPath.row], onCellClick: { podcastId in
            let controller = (self.storyboard?.instantiateViewController(identifier: "PlayerVC")) as! PlayerViewController
            controller.podcasts = self.podcasts
            controller.podcastModel = self.podcasts.first(where: { Podcast in
                Int64(Podcast.id) == podcastId
            })
            controller.modalTransitionStyle = .crossDissolve
            controller.modalPresentationStyle = .fullScreen
            self.present(controller, animated: true, completion: nil)
        }, onCommentsClick: { podcastId in
            if UserDefaults.standard.string(forKey: "authMethod") == nil {
                let controller = (self.storyboard?.instantiateViewController(identifier: "MethodsVC")) as! MethodsViewController
                controller.modalTransitionStyle = .crossDissolve
                controller.modalPresentationStyle = .fullScreen
                self.present(controller, animated: true, completion: nil)
            } else {
                let controller = (self.storyboard?.instantiateViewController(identifier: "CommentVC")) as! CommentsViewController
                controller.podcasts = self.podcasts
                controller.podcastModel = self.podcasts.first(where: { Podcast in
                    Int64(Podcast.id) == podcastId
                })
                controller.modalTransitionStyle = .crossDissolve
                controller.modalPresentationStyle = .fullScreen
                self.present(controller, animated: true, completion: nil)
            }
        }, onLikeClick: { podcastId in
            if UserDefaults.standard.string(forKey: "authMethod") == nil {
                let controller = (self.storyboard?.instantiateViewController(identifier: "MethodsVC")) as! MethodsViewController
                controller.modalTransitionStyle = .crossDissolve
                controller.modalPresentationStyle = .fullScreen
                self.present(controller, animated: true, completion: nil)
            } else {
                let docRef = self.db.collection("likes").document("\(Date().millisecondsSince1970)")
                docRef.setData([
                    "userId": UserDefaults.standard.string(forKey: "idToken"),
                    "podcastId": podcastId
                ])
                { err in
                    if let err = err {
                        print("Error writing document: \(err)")
                    } else {
                        print("Document successfully written!")
                    }
                }
                self.db.collection("likes")
                    .whereField("userId", isEqualTo: UserDefaults.standard.string(forKey: "idToken"))
                    .whereField("podcastId", isEqualTo: podcastId)
                    .getDocuments() { (querySnapshot, err) in
                        if let err = err {
                            print("Error getting documents: \(err)")
                        } else {
                            if querySnapshot?.documents.isEmpty == false {
                                self.db.collection("likes")
                                    .whereField("podcastId", isEqualTo: self.podcasts[indexPath.row].id)
                                    .getDocuments() { (querySnapshot, err) in
                                        if let err = err {
                                            print("Error getting documents: \(err)")
                                        } else {
                                            for document in querySnapshot!.documents {
                                                self.likesCount = querySnapshot!.documents.count
                                                cell.likeCountLabel.text = String(self.likesCount)
                                            }
                                        }
                                    }
                                cell.likeCountLabel.textColor = .black
                                UserDefaults.standard.set("pressedLike", forKey: "likeImage")
                                cell.likeButton.setImage(UIImage(named: UserDefaults.standard.string(forKey: "likeImage")!), for: .normal)
                            } else {
                                UserDefaults.standard.set("emptyLike", forKey: "likeImage")
                                cell.likeButton.setImage(UIImage(named: UserDefaults.standard.string(forKey: "likeImage")!), for: .normal)
                            }
                        }
                    }
                if cell.likeButton.image(for: .normal) == UIImage(named: "pressedLike") {
                    self.db.collection("likes")
                        .whereField("userId", isEqualTo: UserDefaults.standard.string(forKey: "idToken"))
                        .whereField("podcastId", isEqualTo: podcastId)
                        .getDocuments() { (querySnapshot, err) in
                            if let err = err {
                                print("Error getting documents: \(err)")
                            } else {
                                for document in querySnapshot!.documents {
                                    document.reference.delete()
                                    self.db.collection("likes")
                                        .whereField("podcastId", isEqualTo: self.podcasts[indexPath.row].id)
                                        .getDocuments() { (querySnapshot, err) in
                                            if let err = err {
                                                print("Error getting documents: \(err)")
                                            } else {
                                                for document in querySnapshot!.documents {
                                                    self.likesCount = querySnapshot!.documents.count
                                                    cell.likeCountLabel.text = String(self.likesCount)
                                                }
                                            }
                                        }
                                    cell.likeCountLabel.textColor = .white
                                    cell.likeButton.setImage(UIImage(named: "emptyLike"), for: .normal)
                                    UserDefaults.standard.set("emptyLike", forKey: "likeImage")
                                }
                            }
                        }
                }
            }
        })
        self.db.collection("likes")
            .whereField("userId", isEqualTo: UserDefaults.standard.string(forKey: "idToken"))
            .whereField("podcastId", isEqualTo: podcasts[indexPath.row].id)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    if querySnapshot?.documents.isEmpty == false {
                        cell.likeCountLabel.textColor = .black
                        UserDefaults.standard.set("pressedLike", forKey: "likeImage")
                        cell.likeButton.setImage(UIImage(named: UserDefaults.standard.string(forKey: "likeImage")!), for: .normal)
                    } else {
                        UserDefaults.standard.set("emptyLike", forKey: "likeImage")
                        cell.likeButton.setImage(UIImage(named: UserDefaults.standard.string(forKey: "likeImage")!), for: .normal)
                    }
                }
            }
        self.db.collection("comments")
            .whereField("podcastId", isEqualTo: podcasts[indexPath.row].id)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        self.commentsCount = querySnapshot!.documents.count
                        cell.commentsCountLabel.text = String(self.commentsCount)
                    }
                }
            }
        self.db.collection("likes")
            .whereField("podcastId", isEqualTo: podcasts[indexPath.row].id)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        self.likesCount = querySnapshot!.documents.count
                        cell.likeCountLabel.text = String(self.likesCount)
                    }
                }
            }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = podcastCollectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HeaderCollectionReusableView.identifier, for: indexPath) as! HeaderCollectionReusableView
        header.configure()
        
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderSection section: Int) -> CGSize {
        return CGSize(width: podcastCollectionView.frame.size.width, height: 100)
    }
}
