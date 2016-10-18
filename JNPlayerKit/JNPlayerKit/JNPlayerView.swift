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
    
}

private protocol JNPlayerDelegate: class {
    func jnPlayerStatusChanged(status:JNPlayerStatus)
    
    func jnPlayerTimeChanged(currentTime: NSTimeInterval, totalTime:NSTimeInterval)

    func jnPlayerLoadedChanged(loadedTime: NSTimeInterval, totalTime: NSTimeInterval)
}


@objc protocol JNPlayerControl {
    func play()
    func pause()
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
    
    private var player:JNPlayer = JNPlayer()
    
    public var status:JNPlayerStatus = .Pause{
        didSet{
            self.playerControl.playerStatus = status
        }
    }
    
    public weak var delegate:JNPlayerViewDelegate? = nil
    
    public var autoPlay:Bool = true
    
    private var playerControl:JNPlayerControlView = JNPlayerControlView()
    
    public var playingIndex:Int{
        get{
            guard self.playerItems != nil && self.playingItem != nil else {
                return 0
            }
            return self.playerItems?.indexOf({ (element) -> Bool in
                return element.URL == playingItem?.URL
            }) ?? 0
        }
    }
    
    private var playingItem:JNPlayerItem? = nil{
        didSet{
            guard playingItem != nil else{return}
            self.player.URL = NSURL(string: playingItem!.URL)
            self.playerControl.title = playingItem?.title
            self.delegate?.playerView(self, playingItem: playingItem!, index: self.playingIndex)
        }
    }
    
    private var playerItems:[JNPlayerItem]? = nil{
        didSet{
            self.playingItem = playerItems?.first
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setUpUI()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setUpUI()
    }
    
    private func setUpUI(){
        self.translatesAutoresizingMaskIntoConstraints = false
        
        // Player
        self.addSubview(self.player)
        self.player.delegate = self
        self.addConstraints({[unowned self] in
            let left = NSLayoutConstraint(item: self.player, attribute: .Left, relatedBy: .Equal, toItem: self, attribute: .Left, multiplier: 1, constant: 0)
            let top = NSLayoutConstraint(item: self.player, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1, constant: 0)
            let right = NSLayoutConstraint(item: self.player, attribute: .Right, relatedBy: .Equal, toItem: self, attribute: .Right, multiplier: 1, constant: 0)
            let bottom = NSLayoutConstraint(item: self.player, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1, constant: 0)
            return [left, top, right, bottom]
        }())
        
        // PlayerControl
        self.addSubview(self.playerControl)
        self.playerControl.delegate = self
        self.addConstraints({[unowned self] in
            let left = NSLayoutConstraint(item: self.playerControl, attribute: .Left, relatedBy: .Equal, toItem: self, attribute: .Left, multiplier: 1, constant: 0)
            let top = NSLayoutConstraint(item: self.playerControl, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1, constant: 0)
            let right = NSLayoutConstraint(item: self.playerControl, attribute: .Right, relatedBy: .Equal, toItem: self, attribute: .Right, multiplier: 1, constant: 0)
            let bottom = NSLayoutConstraint(item: self.playerControl, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1, constant: 0)
            return [left, top, right, bottom]
        }())
    }
}

extension JNPlayerView: JNPlayerControl, JNPlayerControlDelegate{
    
    public func play(URL:String, title:String? = nil){
        self.play([(URL, title)])
    }
    
    public func play(items:[JNPlayerItem]){
        
        let tmpItems:[JNPlayerItem] = items.map({ (item) -> JNPlayerItem in
            let urlStr = (item.URL as NSString).stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            return (urlStr!, item.title)
        })
        
        self.playerItems = tmpItems
    }
    public func play(index:Int){
        guard index < self.playerItems?.count && index > 0 else{return}
        self.playerControl.showLoading()
        self.playingItem = self.playerItems?[index]
    }
    
    // 播放下一个
    public func playNext(){
        self.play(self.playingIndex + 1)
    }
    
    // 播放上一个
    public func playLast(){
        self.play(self.playingIndex - 1)
    }
    
    
    @objc internal func play(){
        self.player.play()
        self.status = .Play
    }
    
    @objc internal func pause() {
        self.player.pause()
        self.status = .Pause
    }
    
    public func back() {
        self.changeDeviceOrientation(false)
        self.player.URL = nil
        self.backAction?()
        self.delegate?.playerViewBackAction(self)
    }
    
    func jnPlayerTimes() -> (total: NSTimeInterval, current: NSTimeInterval) {
        if let totalTime = self.player.player?.currentItem?.duration, let currentTime = self.player.player?.currentItem?.currentTime(){
            
            if totalTime == currentTime{
                self.status = .PlayEnd
            }
            
            return (CMTimeGetSeconds(totalTime), CMTimeGetSeconds(currentTime))
        }else{
            return (0, 0)
        }
    }
    
    func jnPlayerSeekTime(time: NSTimeInterval) {
        
        if time.isNaN {
            return
        }
        if self.player.player?.currentItem?.status == AVPlayerItemStatus.ReadyToPlay {
            let draggedTime = CMTimeMake(Int64(time), 1)
            self.player.player?.seekToTime(draggedTime, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero, completionHandler: { (success) in
                
            })
        }
    }
    
    func jnPlayerFullScreen(full: Bool) {
        if full{
            
            var supportFullScreen:Bool = false
            
            if let support = UIApplication.sharedApplication().delegate?.application?(UIApplication.sharedApplication(), supportedInterfaceOrientationsForWindow: UIApplication.sharedApplication().keyWindow){
            
                supportFullScreen = support.contains([.LandscapeLeft, .LandscapeRight])
            }else{
                let support = UIApplication.sharedApplication().supportedInterfaceOrientationsForWindow(UIApplication.sharedApplication().keyWindow)
                
                supportFullScreen = support.contains([.LandscapeLeft, .LandscapeRight])
            }
            
            guard supportFullScreen else {
                return
            }
            
            self.changeDeviceOrientation(true)
        }else{
            self.changeDeviceOrientation(false)
        }
    }
    
    func changeDeviceOrientation(isHorizontal: Bool){
        if isHorizontal{
            UIDevice.currentDevice().setValue(UIInterfaceOrientation.LandscapeRight.rawValue, forKey: "orientation")
            UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.Fade)
            UIApplication.sharedApplication().setStatusBarOrientation(UIInterfaceOrientation.LandscapeRight, animated: false)
        }else{
            UIDevice.currentDevice().setValue(UIInterfaceOrientation.Portrait.rawValue, forKey: "orientation")
            UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.Fade)
            UIApplication.sharedApplication().setStatusBarOrientation(UIInterfaceOrientation.Portrait, animated: false)
        }
    }
}

extension JNPlayerView: JNPlayerDelegate{
    func jnPlayerStatusChanged(status: JNPlayerStatus) {
        switch status {
        case .Failed:
            print("Fail")
        case .Unknown:
            print("Unknown")
        case .Pause, .Play:
            print("")
        case .ReadyToPlay:
            if let second = self.player.player?.currentTime().seconds where second <= 0{
                self.playerControl.closeLoading()
                
                if self.autoPlay{
                    self.play()
                    self.playerControl.isShow = true
                }
            }
        case .PlayEnd:
            self.status = .PlayEnd
            if status == .PlayEnd && self.playingItem != nil{
                self.delegate?.playerView(self, playEndItem: self.playingItem!)
            }
            if self.autoPlay{
                self.playNext()
            }
        }
    }
    
    private func jnPlayerTimeChanged(currentTime: NSTimeInterval, totalTime: NSTimeInterval) {
        self.playerControl.playProgress = Float(currentTime / totalTime)
        self.playerControl.currentTime = currentTime
        self.playerControl.totalTime = totalTime
    }
    
    private func jnPlayerLoadedChanged(loadedTime: NSTimeInterval, totalTime: NSTimeInterval) {
        self.playerControl.bufferProgress = Float(loadedTime / totalTime)
    }
}

private class JNPlayer: UIView{

    let playerLayer = AVPlayerLayer()
    
    var playerTimeObserverToken:AnyObject?
    
    weak var delegate:JNPlayerDelegate? = nil
    
    var URL:NSURL? = nil{
        didSet{
            if let _ = URL{
                self.playerItem = AVPlayerItem(URL: URL!)
            }else{
                self.playerItem = nil
            }
            self.player?.replaceCurrentItemWithPlayerItem(self.playerItem)
        }
    }
    
    var player:AVPlayer? = nil{
        didSet{
            self.playerLayer.player = player
            let timeScale = CMTimeScale(NSEC_PER_SEC)
            let time = CMTime(seconds: 0.5, preferredTimescale: timeScale)
            
            self.playerTimeObserverToken = self.player?.addPeriodicTimeObserverForInterval(time, queue: dispatch_get_main_queue(), usingBlock: {[unowned self] time in
                
                guard self.player?.currentItem != nil else{
                    return
                }
                
                // update Slider and Progress
                let currentTime = self.player!.currentItem!.currentTime()
                let current = CMTimeGetSeconds(currentTime)
                
                let totalTime = self.player!.currentItem!.duration
                let total = CMTimeGetSeconds(totalTime)
                
                if let urlStr = self.URL?.absoluteString{
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
                playerItem?.addObserver(self, forKeyPath: PlayerItemStatusKey, options: NSKeyValueObservingOptions.New, context: nil)
                playerItem?.addObserver(self, forKeyPath: PlayerLoadTimeRangeKey, options: NSKeyValueObservingOptions.New, context: nil)
                playerItem?.addObserver(self, forKeyPath: PlaybackBufferEmptyKey, options: NSKeyValueObservingOptions.New, context: nil)
                playerItem?.addObserver(self, forKeyPath: PlaybackBufferLikelyToKeepUpKey, options: NSKeyValueObservingOptions.New, context: nil)
                
                NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.playerDidPlayEnd(_:)), name: AVPlayerItemDidPlayToEndTimeNotification, object: nil)
                
                self.player = AVPlayer(playerItem: self.playerItem)
            }
        }
        willSet{
            playerItem?.removeObserver(self, forKeyPath: PlayerItemStatusKey, context: nil)
            playerItem?.removeObserver(self, forKeyPath: PlayerLoadTimeRangeKey, context: nil)
            playerItem?.removeObserver(self, forKeyPath: PlaybackBufferEmptyKey, context: nil)
            playerItem?.removeObserver(self, forKeyPath: PlaybackBufferLikelyToKeepUpKey, context: nil)
            NSNotificationCenter.defaultCenter().removeObserver(self)
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
        self.backgroundColor = UIColor.blackColor()
        self.layer.addSublayer(playerLayer)
        self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect
    }
    
    private override func layoutSubviews() {
        self.playerLayer.frame = self.layer.bounds
    }
    
    private override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        if let item = object as? AVPlayerItem where item == self.player?.currentItem{
            if keyPath == PlayerItemStatusKey{
                switch item.status {
                case .Failed:
                    self.delegate?.jnPlayerStatusChanged(.Failed)
                case .Unknown:
                    self.delegate?.jnPlayerStatusChanged(.Unknown)
                case .ReadyToPlay:
                    self.delegate?.jnPlayerStatusChanged(.ReadyToPlay)
                }
                return
            }
            
            if keyPath == PlayerLoadTimeRangeKey{
                
                let loadTimeRange = item.loadedTimeRanges
                
                if let timeRangeValue = loadTimeRange.first{
                    
                    let timeRange = timeRangeValue.CMTimeRangeValue
                    
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
    
    @objc func playerDidPlayEnd(notification:NSNotification){
        if let item = notification.object as? AVPlayerItem where item == self.player?.currentItem{
            // 清除播放完视频的时间点
            if let urlStr = self.URL?.absoluteString{
                JNCache[urlStr] = nil
            }
            
            self.delegate?.jnPlayerStatusChanged(.PlayEnd)
            
        }
    }
    
    deinit {
        self.URL = nil
        self.playerItem = nil
        self.player = nil
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}

extension JNPlayer:JNPlayerControl{
    @objc private func play(){
        if self.player?.currentItem?.duration == self.player?.currentItem?.currentTime(){
            self.player?.seekToTime(kCMTimeZero)
        }
        
        if let urlStr = self.URL?.absoluteString{
            if let time = JNCache[urlStr]{
                self.player?.seekToTime(time)
            }
        }
        
        self.playerLayer.player?.play()
    }
    
    @objc private func pause() {
        self.playerLayer.player?.pause()
    }
}
