//
//  PlayerViewController.swift
//  romanova
//
//  Created by Roman Fedotov on 26.08.2021.
//

import UIKit
import AVKit
import Kingfisher
import Firebase
import FirebaseFirestore
import FirebaseDynamicLinks

// MARK: - Properties

var player: AVQueuePlayer? = nil
let clientId = "c291bmRjbG91ZDp1c2Vyczo1NDY3OTE3NjA"
var currentPodcastModel: PodcastModel? = nil
var timeObserverToken: Any?
var playerItem: AVPlayerItem?
var isTimeInverted: Bool = false


class PlayerViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var likesCountLabel: UILabel!
    @IBOutlet weak var commentsCountLabel: UILabel!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var podcastDuration: UILabel!
    @IBOutlet weak var podcastImage: UIImageView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var back15Button: UIButton!
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var next15Button: UIButton!
    @IBOutlet weak var waveForm: WaveFormView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var shareButton: UIButton!
    
    // MARK: - Properties
    
    var podcasts: [PodcastModel] = []
    var playlistResponse: PlaylistResponse? = nil
    var podcastModel: PodcastModel? = nil
    let child = SpinnerViewController()
    var likeImage: String = "emptyLikeBlack"
    let db = Firestore.firestore()
    var ru = ""
    var uk = ""
    var commentsCount: Int = 0
    var likesCount: Int = 0
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
        db.collection("comments")
            .whereField("podcastId", isEqualTo: currentPodcastModel?.id)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        self.commentsCount = querySnapshot!.documents.count
                    }
                    self.commentsCountLabel.text = String(self.commentsCount)
                }
            }
        db.collection("likes")
            .whereField("podcastId", isEqualTo: currentPodcastModel?.id)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        self.likesCount = querySnapshot!.documents.count
                    }
                    self.likesCountLabel.text = String(self.likesCount)
                }
            }
        self.showAlert()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
        do {
            let floatTime = Float(CMTimeGetSeconds((player?.currentTime())!))
            podcastModel?.currentPlayTime = floatTime
            let encoder = JSONEncoder()
            
            let currentPodcast = try encoder.encode(podcastModel)
            UserDefaults.standard.set(currentPodcast, forKey: "currentModel")
        } catch {
            print("Unable to Encode Note (\(error))")
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        podcastImage.backgroundColor = UIColor.clear.withAlphaComponent(0)
        nameLabel.text = NSLocalizedString("screen.player.text.author_name", comment: "")
        descriptionTextView.font = .rounded(ofSize: 16, weight: .regular)
        
        if player == nil || currentPodcastModel != self.podcastModel {
            initPlayer()
        }
        
        if currentPodcastModel == self.podcastModel {
            player?.seek(to: (player?.currentTime())!)
        }
        
        if player?.isPlaying == true {
            playButton.setImage(UIImage(named: "pause"), for: .normal)
        }
        setup()
        addPeriodicTimeObserver()
        setupTapGesture()
        NotificationCenter.default.addObserver(self, selector: #selector(PlayerViewController.finishAudio), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
//        shareButton.isHidden = true
    }
    
    // MARK: - Funcs
    
    @objc func finishAudio()
    {
        nextPodcast()
    }
    
    func initPlayer() {
        currentPodcastModel = self.podcastModel
        let urlStr = "\(podcastModel!.streamUrl)?client_id=\(clientId)"
        let streamURLRequest = StreamUrlRequest(completionHandler: { (result) in
            switch result {
            case .success(let streamResponse):
                if player?.isPlaying == true {
                    player?.pause()
                }
                do {
                    try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
                    playerItem = AVPlayerItem(url: streamResponse.url.asURL!)
                    player = AVQueuePlayer(playerItem: playerItem)
                    self.addPeriodicTimeObserver()
                    DispatchQueue.main.async {
                        self.playButton.setImage(UIImage(named: "pause"), for: .normal)
                    }
                    if player?.isPlaying == false {
                        player?.play()
                    }
                } catch {}
            case .failure(let error):
                break
            }
        }).getStreamUrl(streamUrl: urlStr)
        setup()
    }
    
    
    func nextPodcast() {
        let podcastIndex = self.podcasts.lastIndex { PodcastModel in
            PodcastModel.id == self.podcastModel?.id
        }
        
        let podcast: PodcastModel;
        if podcastIndex == self.podcasts.count - 1 {
            podcast = podcasts.first!
            
        } else {
            
            podcast = podcasts[podcastIndex! + 1]
        }
        self.podcastModel = podcast
        setup()
        initPlayer()
        player?.play()
        
    }
    
    func createDuration(ms: UInt) -> Duration {
        Duration(seconds: (ms/1000)%60, minutes: (ms/(1000*60))%60, hours: (ms/(1000*60*60)))
    }
    
    func setup() {
        nameLabel.font = .rounded(ofSize: 26, weight: .bold)
        podcastDuration.text = createDuration(ms: UInt(exactly: podcastModel!.duration)!).toString(isTimeInverted: isTimeInverted)
        podcastDuration.font = .rounded(ofSize: 14, weight: .regular)
        downloadImage(from: (podcastModel!.waveformUrl.asURL!))
        setupWaveform(url: podcastModel!.waveformUrl)
        db.collection("likes")
            .whereField("userId", isEqualTo: UserDefaults.standard.string(forKey: "idToken"))
            .whereField("podcastId", isEqualTo: currentPodcastModel!.id)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    if querySnapshot?.documents.isEmpty == false {
                        self.likesCountLabel.textColor = .white
                        self.likeButton.setImage(UIImage(named: "pressedLikeBlack"), for: .normal)
                    } else {
                        self.likesCountLabel.textColor = .black
                        self.likeButton.setImage(UIImage(named: "emptyLikeBlack"), for: .normal)
                    }
                }
            }
        db.collection("descriptions")
            .whereField("podcastId", isEqualTo: currentPodcastModel!.id)
            .getDocuments() { (snapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    if Bundle.main.preferredLocalizations.first == "ru" {
                        for document in snapshot!.documents {
                            self.ru = document.get("ru") as! String
                            self.descriptionTextView.text = "\(self.ru)"
                        }
                    } else {
                        for document in snapshot!.documents {
                            self.uk = document.get("uk") as! String
                            self.descriptionTextView.text = "\(self.uk)"
                        }
                    }
                }
            }
        titleLabel.text = currentPodcastModel?.title
        titleLabel.font = .rounded(ofSize: 18, weight: .bold)
        
        NotificationCenter.default.post(name: Notification.Name("text"), object: self.podcastModel)
    }
    
    func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapWaveView(_:)))
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(didPanWaveView(_:)))
        let durationTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapDuration(_:)))
        waveForm.addGestureRecognizer(tapGesture)
        waveForm.addGestureRecognizer(panGesture)
        podcastDuration.addGestureRecognizer(durationTapGesture)
    }
    
    @objc func didTapDuration(_ sender: UITapGestureRecognizer) {
        isTimeInverted = !isTimeInverted
        abcd()
    }
    
    func abcd() {
        let time = player!.currentTime()
        
        self.podcastDuration.text = self.createDuration(ms: UInt(CMTimeGetSeconds(time)) * 1000).toString(isTimeInverted: isTimeInverted)
    }
    
    @objc func didPanWaveView(_ sender: UIPanGestureRecognizer) {
        
        guard let duration = player?.currentItem?.duration.seconds else { return }
        
        let point = sender.location(in: waveForm)
        if let percentToSeek = Double?(Double(100 * point.x / waveForm.frame.width)) {
            let secToSeek: CMTime = CMTimeMake(value: Int64((percentToSeek / 100) * duration), timescale: 1)
            let secToSeek1 = createDuration(ms: UInt(((percentToSeek / 100) * duration)) * 1000).toString(isTimeInverted: isTimeInverted)
            podcastDuration.text = secToSeek1
            waveForm.updateProgress(currentPosition: (percentToSeek / 100) * duration)
            if sender.state == .ended {
                player!.seek(to: secToSeek)
            }
        }
    }
    
    @objc func didTapWaveView(_ sender: UITapGestureRecognizer) {
        guard let duration = player?.currentItem?.duration.seconds else { return }
        
        let point = sender.location(in: waveForm)
        if let percentToSeek = Double?(Double(100 * point.x / waveForm.frame.width)) {
            let secToSeek: CMTime = CMTimeMake(value: Int64((percentToSeek / 100) * duration), timescale: 1)
            player!.seek(to: secToSeek)
        }
    }
    
    func addPeriodicTimeObserver() {
        let timeScale = CMTimeScale(NSEC_PER_SEC)
        let time = CMTime(seconds: 0.1, preferredTimescale: timeScale)
        timeObserverToken = player?.addPeriodicTimeObserver(forInterval: time,
                                                            queue: .main) {
            [weak self] time in
            self?.waveForm.updateProgress(currentPosition: Float64(Float((Float64(time.value)/Float64(time.timescale)))))
            
            let time: CMTime = (isTimeInverted ? player?.playingTimeRemaining : player?.currentTime())!
            
            self?.podcastDuration.text = self?.createDuration(ms: UInt(CMTimeGetSeconds(time)) * 1000).toString(isTimeInverted: isTimeInverted)
        }
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
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
    
    func downloadImage(from url: URL) {
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async() { [weak self] in
                print(data)
            }
        }
    }
    
    
    func showShareSheet(url: String) {
        let promoText = "\(currentPodcastModel?.title ?? "")"
        let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        present(activityVC, animated: true, completion: nil)
    }
    
    func setupWaveform(url: String) {
        ImageDownloaderImpl(url: url).download { ImageDownloaderResult in
            if ImageDownloaderResult.hasError {
                
            } else {
                let imageData = ImageDownloaderResult.imageData!
                let valuesResult = WaveformDataProcessorImpl().process(partsCount: self.waveForm.desiredLinesCount, imageData: imageData.imageData, columnsCount: Int(imageData.imageWidth))
                self.waveForm.setup(values: valuesResult.values, duration: Float64(UInt64(exactly: self.podcastModel!.duration)! / 1000))
            }
        }
    }
    
    // MARK: - IBActions
    
    @IBAction func backButtonAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func likeButtonAction(_ sender: UIButton) {
        if UserDefaults.standard.string(forKey: "authMethod") == nil {
            let controller = (self.storyboard?.instantiateViewController(identifier: "MethodsVC")) as! MethodsViewController
            controller.modalTransitionStyle = .crossDissolve
            controller.modalPresentationStyle = .fullScreen
            self.present(controller, animated: true, completion: nil)
        } else {
            let docRef = self.db.collection("likes").document("\(Date().millisecondsSince1970)")
            docRef.setData([
                "userId": UserDefaults.standard.string(forKey: "idToken"),
                "podcastId": currentPodcastModel!.id
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
                .whereField("podcastId", isEqualTo: currentPodcastModel!.id)
                .getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        print("Error getting documents: \(err)")
                    } else {
                        if querySnapshot?.documents.isEmpty == false {
                            self.db.collection("likes")
                                .whereField("podcastId", isEqualTo: currentPodcastModel!.id)
                                .getDocuments() { (querySnapshot, err) in
                                    if let err = err {
                                        print("Error getting documents: \(err)")
                                    } else {
                                        for document in querySnapshot!.documents {
                                            self.likesCount = querySnapshot!.documents.count
                                            self.likesCountLabel.text = String(self.likesCount)
                                        }
                                    }
                                }
                            self.likesCountLabel.textColor = .white
                            self.likeButton.setImage(UIImage(named: "pressedLikeBlack"), for: .normal)
                        } else {
                            self.likesCountLabel.textColor = .black
                            self.likeButton.setImage(UIImage(named: "emptyLikeBlack"), for: .normal)
                        }
                    }
                }
            if likeButton.image(for: .normal) == UIImage(named: "pressedLikeBlack") {
                self.db.collection("likes")
                    .whereField("userId", isEqualTo: UserDefaults.standard.string(forKey: "idToken"))
                    .whereField("podcastId", isEqualTo: currentPodcastModel!.id)
                    .getDocuments() { (querySnapshot, err) in
                        if let err = err {
                            print("Error getting documents: \(err)")
                        } else {
                            for document in querySnapshot!.documents {
                                document.reference.delete()
                                self.likesCount = querySnapshot!.documents.count - 2
                                self.likesCountLabel.text = String(self.likesCount)
                                self.likesCountLabel.textColor = .black
                                self.likeButton.setImage(UIImage(named: "emptyLikeBlack"), for: .normal)
                            }
                        }
                    }
            }
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
    
    @IBAction func back15ButtonAction(_ sender: UIButton) {
        let currentTime = CMTimeGetSeconds(player!.currentTime())
        var newTime = currentTime - 15.0
        
        if newTime < 0 {
            newTime = 0
        }
        let time: CMTime = CMTimeMake(value: Int64(newTime * 1000), timescale: 1000)
        player!.seek(to: time)
    }
    
    @IBAction func previousButtonAction(_ sender: UIButton) {
        
        let podcastIndex = self.podcasts.lastIndex { PodcastModel in
            PodcastModel.id == self.podcastModel?.id
        }
        
        let podcast: PodcastModel;
        if podcastIndex == 0 {
            podcast = podcasts.last!
            
        } else {
            
            podcast = podcasts[podcastIndex! - 1]
        }
        if player?.isPlaying == true {
            playButton.setImage(UIImage(named: "play"), for: .normal)
            player?.pause()
        }
        player?.removeTimeObserver(timeObserverToken!)
        player = nil
        self.podcastModel = podcast
        initPlayer()
        setup()
        let db = Firestore.firestore()
        db.collection("likes")
            .whereField("userId", isEqualTo: UserDefaults.standard.string(forKey: "idToken"))
            .whereField("podcastId", isEqualTo: currentPodcastModel!.id)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    if querySnapshot?.documents.isEmpty == false {
                        self.likesCountLabel.textColor = .white
                        self.likeButton.setImage(UIImage(named: "pressedLikeBlack"), for: .normal)
                    } else {
                        self.likesCountLabel.textColor = .black
                        self.likeButton.setImage(UIImage(named: "emptyLikeBlack"), for: .normal)
                    }
                }
            }
        
    }
    @IBAction func nextButtonAction(_ sender: UIButton) {
        
        let podcastIndex = self.podcasts.lastIndex { PodcastModel in
            PodcastModel.id == self.podcastModel?.id
        }
        
        let podcast: PodcastModel;
        if podcastIndex == self.podcasts.count - 1 {
            podcast = podcasts.first!
            
        } else {
            
            podcast = podcasts[podcastIndex! + 1]
        }
        if player?.isPlaying == true {
            playButton.setImage(UIImage(named: "play"), for: .normal)
            player?.pause()
        }
        player?.removeTimeObserver(timeObserverToken!)
        player = nil
        self.podcastModel = podcast
        initPlayer()
        setup()
        let db = Firestore.firestore()
        db.collection("likes")
            .whereField("userId", isEqualTo: UserDefaults.standard.string(forKey: "idToken"))
            .whereField("podcastId", isEqualTo: currentPodcastModel!.id)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    if querySnapshot?.documents.isEmpty == false {
                        self.likesCountLabel.textColor = .white
                        self.likeButton.setImage(UIImage(named: "pressedLikeBlack"), for: .normal)
                    } else {
                        self.likesCountLabel.textColor = .black
                        self.likeButton.setImage(UIImage(named: "emptyLikeBlack"), for: .normal)
                    }
                }
            }
    }
    
    @IBAction func next15ButtonAction(_ sender: UIButton) {
        guard let duration = player?.currentItem?.duration else { return }
        let currentTime = CMTimeGetSeconds(player!.currentTime())
        let newTime = currentTime + 15.0
        
        if newTime < (CMTimeGetSeconds(duration) - 15.0) {
            let time: CMTime = CMTimeMake(value: Int64(newTime * 1000), timescale: 1000)
            player!.seek(to: time)
        }
    }
    
    @IBAction func commentButton(_ sender: UIButton) {
        if UserDefaults.standard.string(forKey: "authMethod") == nil {
            let controller = (self.storyboard?.instantiateViewController(identifier: "MethodsVC")) as! MethodsViewController
            controller.modalTransitionStyle = .crossDissolve
            controller.modalPresentationStyle = .fullScreen
            self.present(controller, animated: true, completion: nil)
        } else {
            let controller = (self.storyboard?.instantiateViewController(identifier: "CommentVC")) as! CommentsViewController
            controller.podcastModel = currentPodcastModel
            controller.modalTransitionStyle = .crossDissolve
            controller.modalPresentationStyle = .fullScreen
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    @IBAction func shareButtonAction(_ sender: UIButton) {
        guard let podcast = self.podcastModel else { return }
//        let linkParam = URL(string: "https://romanova.com/podcasts?podcastid=\(currentPodcastModel?.id)")
        var components = URLComponents()
        components.scheme = "https"
        components.host = "romanova.com"
        components.path = "/podcasts"
        
        let podcastIDQueryItem = URLQueryItem(name: "podcastid", value: String(currentPodcastModel!.id))
        components.queryItems = [podcastIDQueryItem]
        
        guard let linkParam = components.url else { return }
        print(linkParam.absoluteString)
        
        guard let shareLink = DynamicLinkComponents.init(link: linkParam, domainURIPrefix: "https://romanovapodcasts.page.link") else { return }
        if let myBundle = Bundle.main.bundleIdentifier {
            shareLink.iOSParameters = DynamicLinkIOSParameters(bundleID: myBundle)
        }
        shareLink.iOSParameters?.appStoreID = "1587390788"
        shareLink.androidParameters = DynamicLinkAndroidParameters(packageName: "com.tma.romanova")
        
        guard let longURL = shareLink.url else { return }
        print(longURL.absoluteString)
        
        shareLink.shorten { (url, warnings, error) in
            if let error = error {
                print(error)
                return
            }
            if let warnings = warnings {
                for warning in warnings {
                    print(warning)
                }
            }
            guard let url = url else { return }
            if currentPodcastModel?.id == 1164740470 {
                self.showShareSheet(url: "https://romanovapodcasts.page.link/podcasts")
            } else if currentPodcastModel?.id == 1164740485 {
                self.showShareSheet(url: "https://romanovapodcasts.page.link/podcast2")
            } else if currentPodcastModel?.id == 1164740509 {
                self.showShareSheet(url: "https://romanovapodcasts.page.link/podcast3")
            } else if currentPodcastModel?.id == 1164740530 {
                self.showShareSheet(url: "https://romanovapodcasts.page.link/podcast4")
            } else if currentPodcastModel?.id == 1164740575 {
                self.showShareSheet(url: "https://romanovapodcasts.page.link/podcast5")
            } else if currentPodcastModel?.id == 1164740638 {
                self.showShareSheet(url: "https://romanovapodcasts.page.link/podcast6")
            } else if currentPodcastModel?.id == 1164740665 {
                self.showShareSheet(url: "https://romanovapodcasts.page.link/podcast7")
            } else if currentPodcastModel?.id == 1164740752 {
                self.showShareSheet(url: "https://romanovapodcasts.page.link/podcast8")
            }
        }
    }
}
