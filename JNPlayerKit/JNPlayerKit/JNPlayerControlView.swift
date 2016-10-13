//
//  JNPlayerControlView.swift
//  JNPlayerKit
//
//  Created by mac on 16/10/12.
//  Copyright © 2016年 Magugi. All rights reserved.
//

import UIKit

protocol JNPlayerControlDelegate:JNPlayerControl {}

// MARK: 播放控制器
class JNPlayerControlView: UIView {
    
    typealias PlayerAction = () -> Void
    
    let topControl:TopControlView = TopControlView()
    let middleControl:MiddleControlView = MiddleControlView()
    let bottomControl:BottomControlView = BottomControlView()
    
    weak var delegate:JNPlayerControlDelegate? = nil

    var playerStatus:JNPlayerStatus = .Pause{
        didSet{
            self.middleControl.playerStatus = playerStatus
        }
    }
    
    var bufferProgress:Float{
        get{
            return self.bottomControl.bufferProgress
        }
        set{
            self.bottomControl.bufferProgress = newValue
        }
    }
    
    var playProgress:Float{
        get{
            return self.bottomControl.playProgress
        }
        set{
            self.bottomControl.playProgress = newValue
        }
    }
    
    let timeFormatter = {(seconds: NSTimeInterval) -> String in
        let Min = Int(seconds / 60)
        let Sec = Int(seconds % 60)
        return String(format: "%02d:%02d", Min, Sec)
    }
    
    var currentTime:NSTimeInterval{
        get{
            return 0
        }
        set{
            self.bottomControl.playedTimeLabel.text = timeFormatter(newValue)
        }
    }
    
    var totalTime:NSTimeInterval{
        get{
            return 0
        }
        set{
            self.bottomControl.totalTimeLabel.text = timeFormatter(newValue)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setUpUI()
        self.setUpAction()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setUpUI()
        self.setUpAction()
    }
    
    func setUpUI(){
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = UIColor.clearColor()
        
        [self.topControl, self.middleControl, self.bottomControl].forEach({self.addSubview($0)})
        
        // TopControl Layout
        self.addConstraints({[unowned self] in
            let left = NSLayoutConstraint(item: self.topControl, attribute: .Left, relatedBy: .Equal, toItem: self, attribute: .Left, multiplier: 1, constant: 0)
            let top = NSLayoutConstraint(item: self.topControl, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1, constant: 0)
            let right = NSLayoutConstraint(item: self.topControl, attribute: .Right, relatedBy: .Equal, toItem: self, attribute: .Right, multiplier: 1, constant: 0)
            return [left, top, right]
        }())

        // MiddleControl Layout
        self.addConstraints({[unowned self] in
            let centerX = NSLayoutConstraint(item: self.middleControl, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant: 0)
            let centerY = NSLayoutConstraint(item: self.middleControl, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 0)
            return [centerX, centerY]
        }())
        
        // BottomControl Layout
        self.addConstraints({[unowned self] in
            let left = NSLayoutConstraint(item: self.bottomControl, attribute: .Left, relatedBy: .Equal, toItem: self, attribute: .Left, multiplier: 1, constant: 0)
            let right = NSLayoutConstraint(item: self.bottomControl, attribute: .Right, relatedBy: .Equal, toItem: self, attribute: .Right, multiplier: 1, constant: 0)
            let bottom = NSLayoutConstraint(item: self.bottomControl, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1, constant: 0)
            return [left, right, bottom]
        }())
        
        self.layoutIfNeeded()
    }
    
    func setUpAction(){
        
        self.middleControl.playAction = {[unowned self] in self.delegate?.play()}
        
        self.middleControl.pauseAction = {[unowned self] in self.delegate?.pause()}
    }
    
    // MARK: 顶部控制器
    class TopControlView: UIView{
        override init(frame: CGRect) {
            super.init(frame: frame)
            self.setUpUI()
        }
        
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            self.setUpUI()
        }
        
        func setUpUI(){
            self.translatesAutoresizingMaskIntoConstraints = false
            self.backgroundColor = UIColor.blueColor()
            self.addConstraint({[unowned self] in
                let height = NSLayoutConstraint(item: self, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 40)
                return height
            }())
            self.layoutIfNeeded()
        }
    }
    
    // MARK: 中间控制器
    class MiddleControlView: UIView{
        
        var playerStatus:JNPlayerStatus = .Pause{
            didSet{
                switch playerStatus {
                case .Pause:
                    self.pauseButton.hidden = true
                    self.playButton.hidden = false
                case .Play:
                    self.pauseButton.hidden = false
                    self.playButton.hidden = true
                }
            }
        }
        
        var playAction:PlayerAction?
        var pauseAction:PlayerAction?
        
        let playButton:UIButton = {
            let button = UIButton()
            button.setTitle("播放", forState: .Normal)
            button.hidden = true
            return button
        }()
        
        let pauseButton:UIButton = {
            let button = UIButton()
            button.setTitle("暂停", forState: .Normal)
            button.hidden = true
            return button
        }()
        
        let loadingView:UIActivityIndicatorView = {
            let indicator = UIActivityIndicatorView()
            indicator.hidesWhenStopped = true
            indicator.color = UIColor.yellowColor()
            return indicator
        }()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            self.setUpUI()
            self.setUpAction()
        }
        
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            self.setUpUI()
            self.setUpAction()
        }
        
        func setUpUI(){
            self.translatesAutoresizingMaskIntoConstraints = false
            self.backgroundColor = UIColor.clearColor()
            
            [self.pauseButton, self.playButton, self.loadingView].forEach({[unowned self] item in
                item.translatesAutoresizingMaskIntoConstraints = false
                self.addSubview(item)
                let width = NSLayoutConstraint(item: item, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 40)
                let height = NSLayoutConstraint(item: item, attribute: .Height, relatedBy: .Equal, toItem: item, attribute: .Width, multiplier: 1, constant: 0)
                item.addConstraints([width, height])
            })
            
            self.addConstraints({[unowned self] in
                
                let width = NSLayoutConstraint(item: self, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 40)
                let height = NSLayoutConstraint(item: self, attribute: .Height, relatedBy: .Equal, toItem: self, attribute: .Width, multiplier: 1, constant: 0)
                
                var constArr:[NSLayoutConstraint] = []
                for item in [self.playButton, self.pauseButton, self.loadingView]{
                    let centerX = NSLayoutConstraint(item: item, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant: 0)
                    let centerY = NSLayoutConstraint(item: item, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 0)
                    constArr.append(centerX)
                    constArr.append(centerY)
                }
                
                return [width, height] + constArr
            }())

            
            self.loadingView.startAnimating()
            
            self.layoutIfNeeded()
        }
        
        func setUpAction(){
            [self.playButton, self.pauseButton].forEach({[unowned self] in $0.addTarget(self, action: #selector(self.playAction(_:)), forControlEvents: .TouchUpInside)})
        }
        
        func playAction(sender:UIButton){
            sender.hidden = true
            
            switch sender {
            case self.playButton:
                self.playAction?()
                self.pauseButton.hidden = false
            case self.pauseButton:
                self.pauseAction?()
                self.playButton.hidden = false
            default:
                print("")
            }
        }
        
        func closeLoading(){
            self.loadingView.stopAnimating()
            self.playerStatus = .Pause
        }
    }
    
    // MARK: 底部控制器
    class BottomControlView: UIView{
        
        var fullScreenAction:PlayerAction?
        var nonFullScreenAction:PlayerAction?
        
        var bufferProgress:Float{
            get{
                return self.processView.bufferProgress
            }
            set{
                self.processView.bufferProgress = newValue
            }
        }
        
        var playProgress:Float{
            get{
                return self.processView.playProgress
            }
            set{
                self.processView.playProgress = newValue
            }
        }
        
        let processView:ProgressView = ProgressView()
        
        private let totalTimeLabel:UILabel = {
            let label = UILabel()
            label.text = "00:00"
            return label
        }()
        
        private let playedTimeLabel:UILabel = {
            let label = UILabel()
            label.text = "10:00"
            return label
        }()
        
        let fullScreenButton: UIButton = {
            let button = UIButton()
            button.setTitle("全屏", forState: .Normal)
            return button
        }()
        
        let nonFullScreenButton: UIButton = {
            let button = UIButton()
            button.setTitle("非全屏", forState: .Normal)
            return button
        }()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            self.setUpUI()
            self.setUpAction()
        }
        
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            self.setUpUI()
            self.setUpAction()
        }
        
        func setUpUI(){
            self.translatesAutoresizingMaskIntoConstraints = false
            self.backgroundColor = UIColor.blueColor()
            self.addConstraint({[unowned self] in
                let height = NSLayoutConstraint(item: self, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 40)
                return height
            }())
            
            [self.processView, self.totalTimeLabel, self.playedTimeLabel,self.fullScreenButton, self.nonFullScreenButton].forEach({[unowned self] in
                
                $0.translatesAutoresizingMaskIntoConstraints = false
                self.addSubview($0)
                
            })
            
            self.addConstraints({[unowned self] in
                
                // Fullscreen button layout
                let fullRight = NSLayoutConstraint(item: self.fullScreenButton, attribute: .Right, relatedBy: .Equal, toItem: self, attribute: .Right, multiplier: 1, constant: -10)
                let fullCenterY = NSLayoutConstraint(item: self.fullScreenButton, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 0)
                
                // NonFullscreen button layout
                let nonFullRight = NSLayoutConstraint(item: self.nonFullScreenButton, attribute: .Right, relatedBy: .Equal, toItem: self, attribute: .Right, multiplier: 1, constant: 0)
                let nonFullCenterY = NSLayoutConstraint(item: self.nonFullScreenButton, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 0)
                
                // PlayedTimeLabel layout
                let playedLeft = NSLayoutConstraint(item: self.playedTimeLabel, attribute: .Left, relatedBy: .Equal, toItem: self, attribute: .Left, multiplier: 1, constant: 10)
                let playedCenterY = NSLayoutConstraint(item: self.playedTimeLabel, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 0)
                
                // TotalTimeLabel layout
                let totalRight = NSLayoutConstraint(item: self.totalTimeLabel, attribute: .Right, relatedBy: .Equal, toItem: self.fullScreenButton, attribute: .Left, multiplier: 1, constant: -10)
                let totalCenterY = NSLayoutConstraint(item: self.totalTimeLabel, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 0)
                
                // Progressview layout
                let progressLeft = NSLayoutConstraint(item: self.processView, attribute: .Left, relatedBy: .Equal, toItem: self.playedTimeLabel, attribute: .Right, multiplier: 1, constant: 0)
                let progressTop = NSLayoutConstraint(item: self.processView, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1, constant: 0)
                let progressRight = NSLayoutConstraint(item: self.processView, attribute: .Right, relatedBy: .Equal, toItem: self.totalTimeLabel, attribute: .Left, multiplier: 1, constant: 0)
                let progressBottom = NSLayoutConstraint(item: self.processView, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1, constant: 0)
                
                return [fullRight, fullCenterY, nonFullRight, nonFullCenterY, playedLeft, playedCenterY, totalRight, totalCenterY, progressLeft, progressTop, progressRight, progressBottom]
            }())
            
            self.nonFullScreenButton.hidden = true
            
            self.layoutIfNeeded()
        }
        
        func setUpAction(){
            [self.fullScreenButton, self.nonFullScreenButton].forEach({[unowned self] in
                $0.addTarget(self, action: #selector(self.playActions(_:)), forControlEvents: .TouchUpInside)
            })
        }
        
        func playActions(sender:UIButton){
            
            sender.hidden = true
            
            switch sender {
            case self.fullScreenButton:
                self.fullScreenAction?()
                self.nonFullScreenButton.hidden = false
                
            case self.nonFullScreenButton:
                self.nonFullScreenAction?()
                self.fullScreenButton.hidden = false
                
            default:
                print("")
            }
        }
        
        class ProgressView:UIView{
            
            var bufferProgress:Float{
                get{
                    return self.progressView.progress
                }
                set{
                    self.progressView.progress = newValue
                }
            }
            
            var playProgress:Float{
                get{
                    return self.slider.value
                }
                set{
                    self.slider.setValue(newValue, animated: true)
                }
            }
            
            let progressView:UIProgressView = {
                let pro = UIProgressView()
                pro.tintColor = UIColor.greenColor()
                pro.trackTintColor = UIColor.yellowColor()
                pro.progress = 0.5
                return pro
            }()
            
            let slider:UISlider = UISlider()
            
            override init(frame: CGRect) {
                super.init(frame: frame)
                self.setUpUI()
                self.setUpAction()
            }
            
            required init?(coder aDecoder: NSCoder) {
                super.init(coder: aDecoder)
                self.setUpUI()
                self.setUpAction()
            }
            
            func setUpUI(){
                self.backgroundColor = UIColor.cyanColor()
                self.translatesAutoresizingMaskIntoConstraints = false
                
                [self.progressView, self.slider].forEach({[unowned self] in
                    self.addSubview($0)
                    $0.translatesAutoresizingMaskIntoConstraints = false
                    let height = NSLayoutConstraint(item: $0, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 10)
                    $0.addConstraint(height)
                })
                
                self.addConstraints({[unowned self] in
                    // Progress layout
                    let progressLeft = NSLayoutConstraint(item: self.progressView, attribute: .Left, relatedBy: .Equal, toItem: self, attribute: .Left, multiplier: 1, constant: 0)
                    let progressRight = NSLayoutConstraint(item: self.progressView, attribute: .Right, relatedBy: .Equal, toItem: self, attribute: .Right, multiplier: 1, constant: 0)
                    let progressCenterY = NSLayoutConstraint(item: self.progressView, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 0)
                    
                    // Slider layout
                    let sliderLeft = NSLayoutConstraint(item: self.slider, attribute: .Left, relatedBy: .Equal, toItem: self, attribute: .Left, multiplier: 1, constant: 0)
                    let sliderRight = NSLayoutConstraint(item: self.slider, attribute: .Right, relatedBy: .Equal, toItem: self, attribute: .Right, multiplier: 1, constant: 0)
                    let sliderCenterY = NSLayoutConstraint(item: self.slider, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 0)
                    
                    return [progressLeft, progressRight, progressCenterY, sliderLeft, sliderRight, sliderCenterY]
                }())
                
            }
            
            func setUpAction(){
                
            }
        }
    }

}

extension JNPlayerControlView{
    func closeLoading() {
        self.middleControl.closeLoading()
    }
}
