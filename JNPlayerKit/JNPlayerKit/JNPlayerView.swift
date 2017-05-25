//
//  JNPlayerView.swift
//  JNPlayerKit
//
//  Created by mac on 16/10/12.
//  Copyright © 2016年 Magugi. All rights reserved.
//

import UIKit
import AVFoundation

public typealias JNPlayerItem = (URL:String, title:String?)

public protocol JNPlayerViewDelegate: class{
    
    // 当前正在播放的视频, 该方法会在加载视频时执行
    func playerView(player:JNPlayerView, playingItem:JNPlayerItem, index:Int)
    
    // 播放完成的视频, 该方法会在视频播放完成时执行
    func playerView(player:JNPlayerView, playEndItem:JNPlayerItem)
    
    // 返回按钮点击回调
    func playerViewBackAction(player:JNPlayerView)
    
    // 播放失败
    func playerView(player:JNPlayerView, playingItem:JNPlayerItem, error:NSError)
    
    
    /// 是否播放item
    ///
    /// - Parameters:
    ///   - player: 播放器
    ///   - willPlayItem: 将要播放的item
    /// - Returns: true OR false
    func playerViewWillPlayItem(player:JNPlayerView, willPlayItem:JNPlayerItem) -> Bool
}

private protocol JNPlayerDelegate: class {
    func jnPlayerStatusChanged(_ status:JNPlayerStatus)
    
    func jnPlayerTimeChanged(_ currentTime: TimeInterval, totalTime:TimeInterval)

    func jnPlayerLoadedChanged(_ loadedTime: TimeInterval, totalTime: TimeInterval)
}

public enum JNPlayerStatus {
    case Play
    case Pause
    case PlayEnd
    case Failed
    case Unknown
    case ReadyToPlay
}

public class JNPlayerView: UIView {
    
    public var backAction:(() -> Void)?
    
    fileprivate var player:JNPlayer = JNPlayer()
    
    public var status:JNPlayerStatus = .Pause{
        didSet{
            self.playerControl.playerStatus = status
        }
    }
    
    public weak var delegate:JNPlayerViewDelegate? = nil
    
    public var autoPlay:Bool = true
    
    fileprivate var playerControl:JNPlayerControlView = JNPlayerControlView()
    
    public var playingIndex:Int{
        get{
            guard self.playerItems != nil && self.playingItem != nil else {
                return 0
            }
            return self.playerItems?.index(where: { (element) -> Bool in
                return element.URL == playingItem?.URL
            }) ?? 0
        }
    }
    
    fileprivate var playingItem:JNPlayerItem? = nil{
        didSet{
            guard playingItem != nil else{return}
            self.player.url = URL(string: playingItem!.URL)
            self.playerControl.title = playingItem?.title
            
            self.delegate?.playerView(player: self, playingItem: playingItem!, index: playingIndex)
            //self.delegate?.playerView(self, playingItem: playingItem!, index: self.playingIndex)
        }
    }
    
    fileprivate var playerItems:[JNPlayerItem]? = nil{
        didSet{
            self.playingItem = playerItems?.first
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        NotificationCenter.default.addObserver(self, selector: #selector(self.appWillResignActiveNotification(notification:)), name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
        self.setUpUI()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setUpUI()
    }
    
    fileprivate func setUpUI(){
        self.translatesAutoresizingMaskIntoConstraints = false
        
        // Player
        self.addSubview(self.player)
        self.player.delegate = self
        self.addConstraints({[unowned self] in
            let left = NSLayoutConstraint(item: self.player, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 0)
            let top = NSLayoutConstraint(item: self.player, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0)
            let right = NSLayoutConstraint(item: self.player, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: 0)
            let bottom = NSLayoutConstraint(item: self.player, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0)
            return [left, top, right, bottom]
        }())
        
        // PlayerControl
        self.addSubview(self.playerControl)
        self.playerControl.delegate = self
        self.addConstraints({[unowned self] in
            let left = NSLayoutConstraint(item: self.playerControl, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 0)
            let top = NSLayoutConstraint(item: self.playerControl, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0)
            let right = NSLayoutConstraint(item: self.playerControl, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: 0)
            let bottom = NSLayoutConstraint(item: self.playerControl, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0)
            return [left, top, right, bottom]
        }())
    }
    
    func appWillResignActiveNotification(notification:NSNotification){
        self.pause()
    }
    
    deinit{
        NotificationCenter.default.removeObserver(self)
    }
}

extension JNPlayerView{
    public func play(url:String?, title:String? = nil){
        guard url != nil else {
            self.player.url = nil
            self.playerItems = nil
            return
        }
        
        self.play(items: [(url!, title)])
    }
    
    public func play(items:[JNPlayerItem]){
        
        let tmpItems:[JNPlayerItem] = items.map({ (item) -> JNPlayerItem in
            let urlStr = (item.URL as NSString).addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
            return (urlStr!, item.title)
        })
        
        self.playerItems = tmpItems
    }
    
    public func play(index:Int){
        guard index < (self.playerItems?.count ?? 0) && index > 0 else{return}
        self.playerControl.showLoading()
        self.playingItem = self.playerItems?[index]
    }
    
    // 播放下一个
    public func playNext(){
        self.play(index: self.playingIndex + 1)
    }
    
    // 播放上一个
    public func playLast(){
        self.play(index: self.playingIndex - 1)
    }
    
    /// 暂停
    public func pause() {
        self.player.pause()
        self.status = .Pause
    }
    
    /// 播放
    public func play() {
        if self.shouldPlay {
            self.player.play()
            self.status = .Play
        }else{
            self.pause()
        }
    }
    
    var shouldPlay:Bool{
        get{
            let canPlay = self.delegate?.playerViewWillPlayItem(player: self, willPlayItem: self.playingItem!) ?? true
            return canPlay
        }
    }
}

extension JNPlayerView: JNPlayerControlDelegate{
    
    internal func ct_play(){
        self.play()
    }
    
    internal func ct_pause() {
        self.pause()
    }
    
    internal func ct_back() {
        if JNTool.deviceIsHorizontal(){
            self.changeDeviceOrientation(isHorizontal: false)
        }else{
            self.player.url = nil
            self.backAction?()
            self.delegate?.playerViewBackAction(player: self)
        }
    }
    
    func ct_jnPlayerTimes() -> (total: TimeInterval, current: TimeInterval) {
        if let totalTime = self.player.player?.currentItem?.duration, let currentTime = self.player.player?.currentItem?.currentTime(){
            
            if totalTime == currentTime{
                self.status = .PlayEnd
            }
            
            return (CMTimeGetSeconds(totalTime), CMTimeGetSeconds(currentTime))
        }else{
            return (0, 0)
        }
    }
    
    func ct_jnPlayerSeekTime(time: TimeInterval) {
        
        if time.isNaN {
            return
        }
        if self.player.player?.currentItem?.status == AVPlayerItemStatus.readyToPlay {
            let draggedTime = CMTimeMake(Int64(time), 1)
            self.player.player?.seek(to: draggedTime, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero, completionHandler: { (success) in
                
            })
        }
    }
    
    func ct_jnPlayerFullScreen(full: Bool) {
        if full{
            
            var supportFullScreen:Bool = false
            
            let support = UIApplication.shared.delegate?.application?(UIApplication.shared, supportedInterfaceOrientationsFor: UIApplication.shared.keyWindow)
            if (support != nil){
                supportFullScreen = support!.contains([.landscapeLeft, .landscapeRight])
            }else{
                let support = UIApplication.shared.supportedInterfaceOrientations(for: UIApplication.shared.keyWindow)
                
                supportFullScreen = support.contains([.landscapeLeft, .landscapeRight])
            }
            
            guard supportFullScreen else {
                return
            }
            
            self.changeDeviceOrientation(isHorizontal: true)
        }else{
            self.changeDeviceOrientation(isHorizontal: false)
        }
    }
    
    func changeDeviceOrientation(isHorizontal: Bool){
        if isHorizontal{
            UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
            UIApplication.shared.setStatusBarHidden(false, with: UIStatusBarAnimation.fade)
            UIApplication.shared.setStatusBarOrientation(UIInterfaceOrientation.landscapeRight, animated: false)
        }else{
            UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
            UIApplication.shared.setStatusBarHidden(false, with: UIStatusBarAnimation.fade)
            UIApplication.shared.setStatusBarOrientation(UIInterfaceOrientation.portrait, animated: false)
        }
    }
}

extension JNPlayerView: JNPlayerDelegate{
    func jnPlayerStatusChanged(_ status: JNPlayerStatus) {
        switch status {
        case .Failed:
            print("Fail")
        case .Unknown:
            print("Unknown")
        case .Pause, .Play:
            print("")
        case .ReadyToPlay:
            if let second = self.player.player?.currentTime().seconds, second <= 0{
                self.playerControl.closeLoading()
                if self.autoPlay{
                    if self.shouldPlay{
                        self.play()
                        self.playerControl.isShow = true
                    }
                }
            }
        case .PlayEnd:
            self.status = .PlayEnd
            if status == .PlayEnd && self.playingItem != nil{
                self.delegate?.playerView(player: self, playEndItem: self.playingItem!)
            }
            if self.autoPlay{
                self.playNext()
            }
        }
    }
    
    fileprivate func jnPlayerTimeChanged(_ currentTime: TimeInterval, totalTime: TimeInterval) {
        self.playerControl.playProgress = Float(currentTime / totalTime)
        self.playerControl.currentTime = currentTime
        self.playerControl.totalTime = totalTime
    }
    
    fileprivate func jnPlayerLoadedChanged(_ loadedTime: TimeInterval, totalTime: TimeInterval) {
        self.playerControl.bufferProgress = Float(loadedTime / totalTime)
    }
}

private class JNPlayer: UIView{

    let playerLayer = AVPlayerLayer()
    
    var playerTimeObserverToken:Any?
    
    weak var delegate:JNPlayerDelegate? = nil
    
    var url:URL? = nil{
        didSet{
            if let _ = url{
                self.playerItem = AVPlayerItem(url: url!)
            }else{
                self.playerItem = nil
            }
            self.player?.replaceCurrentItem(with: self.playerItem)
        }
    }
    
    var player:AVPlayer? = nil{
        didSet{
            self.playerLayer.player = player
            let timeScale = CMTimeScale(NSEC_PER_SEC)
            let time = CMTime(seconds: 0.5, preferredTimescale: timeScale)
            
            self.playerTimeObserverToken = self.player?.addPeriodicTimeObserver(forInterval: time, queue: DispatchQueue.main, using: {[unowned self] time in
                guard self.player?.currentItem != nil else{
                    return
                }
                
                // update Slider and Progress
                let currentTime = self.player!.currentItem!.currentTime()
                let current = CMTimeGetSeconds(currentTime)
                
                let totalTime = self.player!.currentItem!.duration
                let total = CMTimeGetSeconds(totalTime)
                
                if let urlStr = self.url?.absoluteString{
                    if currentTime == totalTime{
                        JNCache[urlStr] = nil
                    }else{
                        JNCache[urlStr] = currentTime
                    }
                }
                
                self.delegate?.jnPlayerTimeChanged(current, totalTime: total)

            })
        }
        willSet{
            if let _ = self.playerTimeObserverToken{
                self.player?.removeTimeObserver(self.playerTimeObserverToken!)
            }
        }
    }
    
    let PlayerItemStatusKey = "status"
    let PlayerLoadTimeRangeKey = "loadedTimeRanges"
    let PlaybackBufferEmptyKey = "playbackBufferEmpty"
    let PlaybackBufferLikelyToKeepUpKey = "playbackLikelyToKeepUp"
    
    private var playerItem:AVPlayerItem? = nil{
        didSet{
            if let _ = playerItem{
                playerItem?.addObserver(self, forKeyPath: PlayerItemStatusKey, options: .new, context: nil)
                playerItem?.addObserver(self, forKeyPath: PlayerLoadTimeRangeKey, options: .new, context: nil)
                playerItem?.addObserver(self, forKeyPath: PlaybackBufferEmptyKey, options: .new, context: nil)
                playerItem?.addObserver(self, forKeyPath: PlaybackBufferLikelyToKeepUpKey, options: .new, context: nil)
                
                NotificationCenter.default.addObserver(self, selector: #selector(self.playerDidPlayEnd(notification:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
                
                self.player = AVPlayer(playerItem: self.playerItem)
            }
        }
        willSet{
            playerItem?.removeObserver(self, forKeyPath: PlayerItemStatusKey, context: nil)
            playerItem?.removeObserver(self, forKeyPath: PlayerLoadTimeRangeKey, context: nil)
            playerItem?.removeObserver(self, forKeyPath: PlaybackBufferEmptyKey, context: nil)
            playerItem?.removeObserver(self, forKeyPath: PlaybackBufferLikelyToKeepUpKey, context: nil)
            NotificationCenter.default.removeObserver(self)
        }
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setUpUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setUpUI()
    }
    
    private func setUpUI(){
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = UIColor.black
        self.layer.addSublayer(playerLayer)
        self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect
    }
    
    fileprivate override func layoutSubviews() {
        self.playerLayer.frame = self.layer.bounds
    }
    
    fileprivate override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let item = object as? AVPlayerItem, item == self.player?.currentItem{
            if keyPath == PlayerItemStatusKey{
                switch item.status {
                case .failed:
                    self.delegate?.jnPlayerStatusChanged(.Failed)
                case .unknown:
                    self.delegate?.jnPlayerStatusChanged(.Unknown)
                case .readyToPlay:
                    self.delegate?.jnPlayerStatusChanged(.ReadyToPlay)
                }
                return
            }
            
            if keyPath == PlayerLoadTimeRangeKey{
                
                let loadTimeRange = item.loadedTimeRanges
                
                if let timeRangeValue = loadTimeRange.first{
                    
                    let timeRange = timeRangeValue.timeRangeValue
                    
                    let start = CMTimeGetSeconds(timeRange.start)
                    let duration = CMTimeGetSeconds(timeRange.duration)
                    
                    let loaded = start + duration
                    let total = CMTimeGetSeconds(item.duration)
                    
                    self.delegate?.jnPlayerLoadedChanged(loaded, totalTime: total)
                }
                
                
                
                return
            }
            
            if keyPath == PlaybackBufferEmptyKey{
                
                return
            }
            
            if keyPath == PlaybackBufferLikelyToKeepUpKey{
                
                return
            }
            
        }
    }
    
//    private func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutableRawPointer) {
//        
//        if let item = object as? AVPlayerItem, item == self.player?.currentItem{
//            if keyPath == PlayerItemStatusKey{
//                switch item.status {
//                case .failed:
//                    self.delegate?.jnPlayerStatusChanged(status: .Failed)
//                case .unknown:
//                    self.delegate?.jnPlayerStatusChanged(status: .Unknown)
//                case .readyToPlay:
//                    self.delegate?.jnPlayerStatusChanged(status: .ReadyToPlay)
//                }
//                return
//            }
//            
//            if keyPath == PlayerLoadTimeRangeKey{
//                
//                let loadTimeRange = item.loadedTimeRanges
//                
//                if let timeRangeValue = loadTimeRange.first{
//                    
//                    let timeRange = timeRangeValue.timeRangeValue
//                    
//                    let start = CMTimeGetSeconds(timeRange.start)
//                    let duration = CMTimeGetSeconds(timeRange.duration)
//                    
//                    let loaded = start + duration
//                    let total = CMTimeGetSeconds(item.duration)
//                    
//                    self.delegate?.jnPlayerLoadedChanged(loadedTime: loaded, totalTime: total)
//                }
//                
//                
//                
//                return
//            }
//            
//            if keyPath == PlaybackBufferEmptyKey{
//                
//                return
//            }
//            
//            if keyPath == PlaybackBufferLikelyToKeepUpKey{
//                
//                return
//            }
//
//        }
//    }
    
    @objc func playerDidPlayEnd(notification:NSNotification){
        if let item = notification.object as? AVPlayerItem, item == self.player?.currentItem{
            // 清除播放完视频的时间点
            if let urlStr = self.url?.absoluteString{
                JNCache[urlStr] = nil
            }
            
            self.delegate?.jnPlayerStatusChanged(.PlayEnd)
            
        }
    }
    
    deinit {
        self.url = nil
        self.playerItem = nil
        self.player = nil
        NotificationCenter.default.removeObserver(self)
    }
}

extension JNPlayer{
    fileprivate func play(){
        if self.player?.currentItem?.duration == self.player?.currentItem?.currentTime(){
            self.player?.seek(to: kCMTimeZero)
        }
        
        if let urlStr = self.url?.absoluteString{
            if let time = JNCache[urlStr]{
                self.player?.seek(to: time)
            }
        }
        
        self.playerLayer.player?.play()
    }
    
    fileprivate func pause() {
        self.playerLayer.player?.pause()
    }
}
