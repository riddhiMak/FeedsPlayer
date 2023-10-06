//
//  FeedsPlayerViewController.swift
//  Seeto
//
//  Created by Riddhi Makwana on 12/09/23.
//

import UIKit
import AVFoundation
import AVKit

extension Notification.Name {
    static let playPlayer = Notification.Name("playPlayer")
}

struct Video {
    var id = UUID()
    var player : AVPlayer
    var url : URL?
    var thumbnail : String?
}

class FeedsPlayerViewController: UIViewController {
    var searchView = false
    var userType = 0
    let screenSize: CGRect = UIScreen.main.bounds
    var mainDataArray = [NSDictionary].init()
    var inputArray = NSDictionary.init()
    var searchJobId = ""
    var videos : [Video] = []
    private var currentIndex: Int = 0
    
    @IBOutlet var btnSearch: UIButton!
    @IBOutlet var btnBack: UIButton!
   
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isPagingEnabled = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.delegate = self
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = UIStackView.Distribution.equalSpacing
        stackView.spacing = 0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.playPlayer), name: .playPlayer, object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.appEnteredFromBackground(_:)),
                                               name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.appEnteredToBackground),
                                               name: UIApplication.willResignActiveNotification, object: nil)
        if let userType = UserDefaults.standard.value(forKey: "userType") as? Int
        {
            self.userType = userType
            if userType == 2
            {
//
            }
            else
            {
                btnSearch.isHidden = false

            }
        }
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
        }
        catch {
            print("Setting category to AVAudioSessionCategoryPlayback failed.")
        }
        
        fillVideoData()
        DispatchQueue.main.async {
            self.setupScrollView()
        }
    }
    
    @objc func appEnteredToBackground() {
        for i in 0..<videos.count{
            self.videos[i].player.pause()
        }
    }
    
    @objc func appEnteredFromBackground(_ notification: NSNotification) {
        if self.isVisible{
                if videos.count > 0
                {
                    self.videos[self.currentIndex].player.seek(to: .zero)
                    self.videos[self.currentIndex].player.play()
                }
        }
    }
    func fillVideoData(){
        
        for i in 0..<videos.count{
            self.videos[i].player.pause()
        }
        
        self.videos.removeAll()
        self.videos.append(Video(player: AVPlayer(url: URL(string: "https://trainingstory.s3.amazonaws.com/Chat_Media/production_id_4620564+(2160p).mp4")!)))
        self.videos.append(Video(player: AVPlayer(url: URL(string: "https://seetoapp.s3.us-east-1.amazonaws.com/6defd1dc-2e47-411f-9b55-cdd05b33ae0b_sample_1280x720_surfing_with_audio.mp4")!)))
        self.videos.append(Video(player: AVPlayer(url: URL(string: "https://trainingstory.s3.amazonaws.com/Chat_Media/production_id_4620564+(2160p).mp4")!)))
        self.videos.append(Video(player: AVPlayer(url: URL(string: "https://seetoapp.s3.us-east-1.amazonaws.com/6defd1dc-2e47-411f-9b55-cdd05b33ae0b_sample_1280x720_surfing_with_audio.mp4")!)))
        self.videos.append(Video(player: AVPlayer(url: URL(string: "https://trainingstory.s3.amazonaws.com/Chat_Media/production_id_4620564+(2160p).mp4")!)))
        self.videos.append(Video(player: AVPlayer(url: URL(string: "https://seetoapp.s3.us-east-1.amazonaws.com/6defd1dc-2e47-411f-9b55-cdd05b33ae0b_sample_1280x720_surfing_with_audio.mp4")!)))
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .playPlayer, object: nil)
        NotificationCenter.default.removeObserver(self, name:NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)

    }
    
    @objc private func playPlayer(){
        if videos.count > 0
        {
            self.videos[self.currentIndex].player.seek(to: .zero)
            self.videos[self.currentIndex].player.play()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
   
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name:NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        if self.videos.count > 0{
            self.videos[self.currentIndex].player.seek(to: .zero)
            self.videos[self.currentIndex].player.pause()
        }
    }
    
    func showToast(iconName : String) {

        let view = UIView(frame: CGRect(x: self.view.frame.size.width/2 - 80, y: self.view.frame.size.height/2 - 80, width: 160, height: 160))
        let toastIcon = UIImageView(frame: CGRect(x: iconName == "close" ? self.view.frame.size.width/2 - 40 : self.view.frame.size.width/2 - 60, y: iconName == "close" ? self.view.frame.size.height/2 - 40 : self.view.frame.size.height/2 - 60, width: iconName == "close" ? 80 : 120, height: iconName == "close" ? 80 : 120))
        view.backgroundColor = UIColor.clear.withAlphaComponent(0.6) // background color with 0.6 ransparency
        view.layer.cornerRadius = view.frame.height / 2 // for rounded image
        view.layer.masksToBounds = true
        view.clipsToBounds = true
        toastIcon.clipsToBounds = true
        let pauseImg = UIImage(named: iconName)
        toastIcon.image = pauseImg
        toastIcon.tintColor = .white
        toastIcon.alpha = 1.0
        self.view.addSubview(view)
        self.view.addSubview(toastIcon)

        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
            view.alpha = 0.0
            toastIcon.alpha = 0.0

                }, completion: {(isCompleted) in
                    view.removeFromSuperview()
                    toastIcon.removeFromSuperview()

        })
    }
    
    
    
    
    @IBAction func btnBackAct(_ sender: UIButton) {
        self.videos[self.currentIndex].player.seek(to: .zero)
        self.videos[self.currentIndex].player.pause()
        for i in 0..<videos.count{
            self.videos[i].player.replaceCurrentItem(with: nil)
        }
        
    }
}


extension FeedsPlayerViewController  : UIScrollViewDelegate {
    
    func setupScrollView() {
        
        self.view.addSubview(scrollView)
        
        scrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        scrollView.addSubview(stackView)
//        self.view.bringSubviewToFront(self.btnSearch)
//        self.view.bringSubviewToFront(self.btnBack)
        stackView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        
        stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 0).isActive = true
        stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: 0).isActive = true
        stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
        stackView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        for i in 0..<videos.count {
            
            let playerView  = PlayerView()
            
            playerView.videos = self.videos[i]
            playerView.index = i
            playerView.btnLike.addTarget(self, action: #selector(likeAct), for: .touchUpInside)
            playerView.btnDisLike.addTarget(self, action: #selector(dislikeAct), for: .touchUpInside)
            playerView.btnDisLike.tag = i
            playerView.btnLike.tag = i
            
            let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(leftSwiped))
            swipeLeft.view?.tag = i
            swipeLeft.direction = UISwipeGestureRecognizer.Direction.left
            playerView.addGestureRecognizer(swipeLeft)
            
            playerView.tag = i
            playerView.setupPlayerView()

            stackView.addArrangedSubview(playerView)
            playerView.heightAnchor.constraint(equalToConstant: screenSize.height).isActive = true

        }
        if self.videos.count > 0{
            self.videos[currentIndex].player.seek(to: .zero)
            self.videos[currentIndex].player.play()
        }
        
    }
    
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let index = Int(scrollView.contentOffset.y / scrollView.bounds.height)
        
        if currentIndex != index {
            videos[currentIndex].player.seek(to: .zero)
            videos[currentIndex].player.pause()
            currentIndex = index
            videos[currentIndex].player.play()
            videos[currentIndex].player.actionAtItemEnd = .none

            NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: videos[currentIndex].player.currentItem, queue: .main) { (_) in
                self.videos[self.currentIndex].player.seek(to: .zero)
                self.videos[self.currentIndex].player.play()
            }
        }
    }
}

extension FeedsPlayerViewController {
    @objc func leftSwiped(_ sender : UISwipeGestureRecognizer)
    {
        self.videos[self.currentIndex].player.seek(to: .zero)
        self.videos[self.currentIndex].player.pause()
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        self.navigationController?.pushViewController(vc, animated: true)
        

    }

    @objc func likeAct(_ sender : UIButton)
    {
        var isRemove = false
        DispatchQueue.main.async {
            for sView in self.scrollView.subviews {
                if let stackView = sView as? UIStackView {
                    for playerview in stackView.subviews {
                        if let playerView = playerview as? PlayerView, playerView.tag == self.currentIndex {
                            UIView.animate(withDuration: 0.5, animations: {
                                self.videos[self.currentIndex].player.seek(to: .zero)
                                self.videos[self.currentIndex].player.pause()
                                self.videos.remove(at: self.currentIndex)
                                print("playerView.tag = \(playerView.tag)")
                                playerView.removeFromSuperview()
                                isRemove = true
                            }, completion: { (_) in
                                if !self.videos.isEmpty{
                                    let newIndex = Int(self.scrollView.contentOffset.y / self.scrollView.bounds.height)
                                    print("newIndex = \(newIndex)")
                                    self.currentIndex = newIndex
                                    if self.videos.count > self.currentIndex{
                                        self.videos[self.currentIndex].player.play()
                                        self.videos[self.currentIndex].player.actionAtItemEnd = .none
                                    }
                                }
                            })
                            
                        }else{
                            if isRemove{
                                if let playerView = playerview as? PlayerView{
                                    playerview.tag = playerview.tag - 1
                                }
                                print(self.scrollView.subviews)
                            }
                        }
                    }
                }
            }
        }
    }
    
    @objc func dislikeAct(_ sender : UIButton)
    {
        var isRemove = false
        DispatchQueue.main.async {
            for sView in self.scrollView.subviews {
                if let stackView = sView as? UIStackView {
                    for playerview in stackView.subviews {
                        if let playerView = playerview as? PlayerView, playerView.tag == self.currentIndex {
                            UIView.animate(withDuration: 0.5, animations: {
                                self.videos[self.currentIndex].player.seek(to: .zero)
                                self.videos[self.currentIndex].player.pause()
                                self.videos.remove(at: self.currentIndex)
                                print("playerView.tag = \(playerView.tag)")
                                playerView.removeFromSuperview()
                                isRemove = true
                            }, completion: { (_) in
                                if !self.videos.isEmpty{
                                    let newIndex = Int(self.scrollView.contentOffset.y / self.scrollView.bounds.height)
                                    print("newIndex = \(newIndex)")
                                    self.currentIndex = newIndex
                                    if self.videos.count > self.currentIndex{
                                        self.videos[self.currentIndex].player.play()
                                        self.videos[self.currentIndex].player.actionAtItemEnd = .none
                                    }
                                }
                            })
                            
                        }else{
                            if isRemove{
                                if let playerView = playerview as? PlayerView{
                                    playerview.tag = playerview.tag - 1
                                }
                                print(self.scrollView.subviews)
                            }
                        }
                    }
                }
            }
        }
    }
    
   
    
}

extension UINavigationController {
        
    func backToViewController(viewController: Swift.AnyClass) {
        for element in viewControllers as Array {
            if element.isKind(of: viewController) {
                self.popToViewController(element, animated: true)
                break
            }
        }
    }
    
}


class PlayerView: UIView {

    var playerViewController: PlayerViewController?
    var videos: Video!
    var index : Int!
    lazy var btnLike: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .black
        button.setImage(UIImage(systemName: "checkmark.seal"), for: .normal)
        button.layer.cornerRadius = 40
        button.layer.masksToBounds = true
        return button
    }()
    
    lazy var btnDisLike: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .black
        button.setImage(UIImage(systemName: "xmark.circle"), for: .normal)
        button.layer.cornerRadius = 40
        button.layer.masksToBounds = true
        return button
    }()
    
    lazy var horizontalStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [btnLike, btnDisLike])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 16
        return stackView
    }()

    func setupPlayerView() {
        guard let firstVideo = videos else {
            return
        }
        
        let player = firstVideo.player
        playerViewController = PlayerViewController(player: player)

        if let playerView = playerViewController?.view {
            playerView.frame = bounds
            addSubview(playerView)
        }
        
        
        addSubview(horizontalStackView)
        NSLayoutConstraint.activate([
            horizontalStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -44),
            horizontalStackView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            horizontalStackView.widthAnchor.constraint(equalToConstant: 176),
            horizontalStackView.heightAnchor.constraint(equalToConstant: 80)
        ])
        
    }

}

class PlayerViewController: AVPlayerViewController {

    init(player: AVPlayer) {
        super.init(nibName: nil, bundle: nil)
        self.player = player
        self.showsPlaybackControls = false
        self.player?.automaticallyWaitsToMinimizeStalling = false
        self.videoGravity = .resizeAspectFill
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension UIViewController {
    public var isVisible: Bool {
        if isViewLoaded {
            return view.window != nil
        }
        return false
    }
    
    public var isTopViewController: Bool {
        if self.navigationController != nil {
            return self.navigationController?.visibleViewController === self
        } else if self.tabBarController != nil {
            return self.tabBarController?.selectedViewController == self && self.presentedViewController == nil
        } else {
            return self.presentedViewController == nil && self.isVisible
        }
    }
}
