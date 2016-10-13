//
//  JNPlayerView.swift
//  JNPlayerKit
//
//  Created by mac on 16/10/12.
//  Copyright © 2016年 Magugi. All rights reserved.
//

import UIKit
import AVFoundation

private protocol JNPlayerDelegate: class {
    func jnPlayerStatusChanged(status:AVPlayerItemStatus)
}


@objc public protocol JNPlayerControl {
    func play()
    func pause()
}

enum JNPlayerStatus {
    case Play
    case Pause
}

public class JNPlayerView: UIView {
    
    private var player:JNPlayer = JNPlayer()
    
    private var playerControl:JNPlayerControlView = JNPlayerControlView()
    
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
    public func play(URL:NSURL, title:String? = nil){
        self.player.URL = URL
    }
    
    public func play(){
        self.player.play()
        self.playerControl.playerStatus = .Play
    }
    
    public func pause() {
        self.player.pause()
        self.playerControl.playerStatus = .Pause
    }
}

extension JNPlayerView: JNPlayerDelegate{
    func jnPlayerStatusChanged(status: AVPlayerItemStatus) {
        switch status {
        case .Failed:
            print("Fail")
        case .Unknown:
            print("Unknown")
        case .ReadyToPlay:
            print("ReadyToPlay")
            self.playerControl.closeLoading()
        }
    }
}

private class JNPlayer: UIView{

    let playerLayer = AVPlayerLayer()
    
    var player:AVPlayer? = nil{
        didSet{
            self.playerLayer.player = player
        }
    }
    
    let PlayerItemStatusContext = UnsafeMutablePointer<()>()
    
    private var playerItem:AVPlayerItem? = nil{
        didSet{
            if let _ = playerItem{
                playerItem?.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.New, context: PlayerItemStatusContext)
                self.player = AVPlayer(playerItem: self.playerItem)
            }
        }
        willSet{
            playerItem?.removeObserver(self, forKeyPath: "status", context: PlayerItemStatusContext)
        }
    }
    
    var URL:NSURL? = nil{
        didSet{
            if let _ = URL{
                self.playerItem = AVPlayerItem(URL: URL!)
            }else{
                self.playerItem = nil
            }
        }
    }
    
    weak var delegate:JNPlayerDelegate? = nil
    
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
        self.backgroundColor = UIColor.redColor()
        self.layer.addSublayer(playerLayer)
        self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect
    }
    
    private override func layoutSubviews() {
        self.playerLayer.frame = self.layer.bounds
    }
    
    private override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if context == PlayerItemStatusContext{
            if let item = object as? AVPlayerItem{
                self.delegate?.jnPlayerStatusChanged(item.status)
                switch item.status {
                case .Failed:
                    print("加载失败")
                case .Unknown:
                    print("未知状态")
                case .ReadyToPlay:
                    print("ReadToPlay")
                }
            }
        }
    }
    
    
    deinit {
        self.URL = nil
        self.playerItem = nil
        self.player = nil
    }
}

extension JNPlayer:JNPlayerControl{
    @objc private func play(){
        self.playerLayer.player?.play()
    }
    
    @objc private func pause() {
        self.playerLayer.player?.pause()
    }
}
