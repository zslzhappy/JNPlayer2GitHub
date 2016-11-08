//
//  JNPlayerControlView.swift
//  JNPlayerKit
//
//  Created by mac on 16/10/12.
//  Copyright © 2016年 Magugi. All rights reserved.
//

import UIKit
import Dispatch

protocol JNPlayerControlDelegate:JNPlayerControl {
    func jnPlayerTimes() -> (total: TimeInterval, current: TimeInterval)
    func jnPlayerSeekTime(time:TimeInterval)
    
    func jnPlayerFullScreen(full:Bool)
    
    func back()
}


// MARK: 播放控制器
class JNPlayerControlView: UIView {
    
    typealias PlayerAction = () -> Void
    
    let topControl:TopControlView = TopControlView()
    let middleControl:MiddleControlView = MiddleControlView()
    let bottomControl:BottomControlView = BottomControlView()
    
    weak var delegate:JNPlayerControlDelegate? = nil
    
    // 上次用户交互时间，用于判断是否隐藏控制器
    fileprivate var lastInteract:NSDate = NSDate(){
        didSet{
            
            let delayTime = DispatchTime.now() + DispatchTimeInterval.seconds(7)
            
            //let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC * 7))
            
            DispatchQueue.main.asyncAfter(deadline: delayTime, execute: {[unowned self] in
                if self.lastInteract.timeIntervalSinceNow < -5{
                    if self.isShow{
                        self.isShow = false
                    }
                }
            })
            
//            dispatch_after(delayTime, dispatch_get_main_queue(), {[unowned self] in
//                if self.lastInteract.timeIntervalSinceNow < -5{
//                    if self.isShow{
//                        self.isShow = false
//                    }
//                }
//            })
        }
    }
    
    // ControlView 当前是否显示
    var isShow:Bool = true{
        didSet{
            self.lastInteract = NSDate()
            if isShow{
                self.showControl()
            }else{
                self.hiddenControl()
            }
        }
    }

    var playerStatus:JNPlayerStatus = .Pause{
        didSet{
            self.middleControl.playerStatus = playerStatus
        }
    }
    
    var title:String?{
        get{
            return self.topControl.titleLabel.text
        }
        set{
            self.topControl.titleLabel.text = newValue
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
    
    let timeFormatter = {(seconds: TimeInterval) -> String in
        if seconds.isNaN{
            return "00:00"
        }
        
        let Min = Int(seconds / 60)
        let Sec = Int(Int(seconds) % Int(60))
        return String(format: "%02d:%02d", Min, Sec)
    }
    
    var currentTime:TimeInterval{
        get{
            return 0
        }
        set{
            self.bottomControl.playedTimeLabel.text = timeFormatter(newValue)
        }
    }
    
    var totalTime:TimeInterval{
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
    
    var topControlTopConstraint:NSLayoutConstraint? = nil
    var bottomControlBottomContraint:NSLayoutConstraint? = nil
    
    func setUpUI(){
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = UIColor.clear
        self.clipsToBounds = true
        
        [self.topControl, self.middleControl, self.bottomControl].forEach({self.addSubview($0)})
        
        // TopControl Layout
        self.addConstraints({[unowned self] in
            let left = NSLayoutConstraint(item: self.topControl, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 0)
            
            let top = NSLayoutConstraint(item: self.topControl, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0)
            self.topControlTopConstraint = top
            
            let right = NSLayoutConstraint(item: self.topControl, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: 0)
            return [left, top, right]
        }())

        // MiddleControl Layout
        self.addConstraints({[unowned self] in
            let centerX = NSLayoutConstraint(item: self.middleControl, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0)
            let centerY = NSLayoutConstraint(item: self.middleControl, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0)
            return [centerX, centerY]
        }())
        
        // BottomControl Layout
        self.addConstraints({[unowned self] in
            let left = NSLayoutConstraint(item: self.bottomControl, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 0)
            let right = NSLayoutConstraint(item: self.bottomControl, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: 0)
            let bottom = NSLayoutConstraint(item: self.bottomControl, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0)
            self.bottomControlBottomContraint = bottom
            return [left, right, bottom]
        }())
        
        self.layoutIfNeeded()
    }
    
    func setUpAction(){
        
        self.topControl.backAction = {[unowned self] in
            self.lastInteract = NSDate()
            self.delegate?.back()
        }
        
        self.middleControl.playAction = {[unowned self] in
            self.lastInteract = NSDate()
            self.delegate?.play()
        }
        
        self.middleControl.pauseAction = {[unowned self] in
            self.lastInteract = NSDate()
            self.delegate?.pause()
        }
        
        self.middleControl.replayAction = {[unowned self] in
            self.lastInteract = NSDate()
            self.delegate?.play()
        }
        
        self.bottomControl.sliderValueChangedAction = {[unowned self] value in
            
            self.lastInteract = NSDate()
            
            let totalTime = self.delegate?.jnPlayerTimes().total ?? 0
            
            let currentTime = totalTime * Double(value)
            
            self.currentTime = currentTime
            
            // player seek time
            self.delegate?.jnPlayerSeekTime(time: currentTime)
        }
        
        self.bottomControl.fullScreenAction = {[unowned self] in
            self.lastInteract = NSDate()
            self.delegate?.jnPlayerFullScreen(full: true)
        }
        
        self.bottomControl.nonFullScreenAction = {[unowned self] in
            self.lastInteract = NSDate()
            self.delegate?.jnPlayerFullScreen(full: false)
        }
        
        let tapGes = UITapGestureRecognizer(target: self, action: #selector(self.tapAction(tap:)))
        
        self.addGestureRecognizer(tapGes)
    }
    
    func tapAction(tap:UITapGestureRecognizer){
        //self.lastInteract = NSDate()
        self.isShow = !self.isShow
    }
    
    func showControl(){
        
        UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseIn, animations: {
            
            // topControl
            self.topControlTopConstraint?.constant = 0
            self.topControl.alpha = 1
            
            // bottomControl
            self.bottomControlBottomContraint?.constant = 0
            self.bottomControl.alpha = 1
            
            // middleControl
            self.middleControl.alpha = 1
            
            self.layoutIfNeeded()
        }, completion: nil)
        
    }
    
    func hiddenControl(){
        UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseIn, animations: {
            
            // topControl
            self.topControlTopConstraint?.constant = -64
            self.topControl.alpha = 0
            
            // bottomControl
            self.bottomControlBottomContraint?.constant = 40
            self.bottomControl.alpha = 0
            
            // middleControl
            self.middleControl.alpha = 0
            
            self.layoutIfNeeded()
            
        }, completion: nil)
    }
    
    // MARK: 顶部控制器
    class TopControlView: UIView{
        
        var backAction:PlayerAction?
        
        let backgroundView:UIView = {
            let view = UIView()
            view.backgroundColor = UIColor.black
            view.alpha = 0.5
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()
        
        let backButton:UIButton = {
            let button = UIButton()
            button.setImage(JNTool.image(name: "jn_player_top_back"), for: .normal)
            button.translatesAutoresizingMaskIntoConstraints = false
            return button
        }()
        
        let titleLabel:UILabel = {
            let lable = UILabel()
            lable.textColor = UIColor.white
            lable.font = UIFont.systemFont(ofSize: 15)
            lable.textAlignment = .left
            lable.translatesAutoresizingMaskIntoConstraints = false
            return lable
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
            self.backgroundColor = UIColor.clear
            
            self.addSubview(self.backgroundView)
            
            self.addSubview(self.backButton)
            self.addSubview(self.titleLabel)
            
            self.backButton.addConstraints({[unowned self] in
                let width = NSLayoutConstraint(item: self.backButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 40)
                let height = NSLayoutConstraint(item: self.backButton, attribute: .height, relatedBy: .equal, toItem: self.backButton, attribute: .width, multiplier: 1, constant: 0)
                return [width, height]
            }())
            
            self.addConstraints({[unowned self] in
                let height = NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 64)
                
                let backgroundCons = JNTool.edges(first: self.backgroundView, second: self)
                
                // backButton layout
                let backLeft = NSLayoutConstraint(item: self.backButton, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 0)
                let backCenterY = NSLayoutConstraint(item: self.backButton, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 10)
                
                // titleLabel layout
                let titleLeft = NSLayoutConstraint(item: self.titleLabel, attribute: .left, relatedBy: .equal, toItem: self.backButton, attribute: .right, multiplier: 1, constant: 1)
                let titleCenterY = NSLayoutConstraint(item: self.titleLabel, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 10)
                let titleRight = NSLayoutConstraint(item: self.titleLabel, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: -10)
                
                return [height, backLeft, backCenterY, titleLeft, titleCenterY, titleRight] + backgroundCons
            }())
            self.layoutIfNeeded()
        }
        
        func setUpAction(){
            self.backButton.addTarget(self, action: #selector(backAction(sender:)), for: .touchUpInside)
        }
        
        func backAction(sender:UIButton){
            self.backAction?()
        }
    }
    
    // MARK: 中间控制器
    class MiddleControlView: UIView{
        
        var playerStatus:JNPlayerStatus = .Pause{
            didSet{
                switch playerStatus {
                case .Pause:
                    self.pauseButton.isHidden = true
                    self.playButton.isHidden = false
                    self.replayButton.isHidden = true
                case .Play:
                    self.pauseButton.isHidden = false
                    self.playButton.isHidden = true
                    self.replayButton.isHidden = true
                case .PlayEnd:
                    self.pauseButton.isHidden = true
                    self.playButton.isHidden = true
                    self.replayButton.isHidden = false
                default:
                    print("other status")
                }
            }
        }
        
        var playAction:PlayerAction?
        var pauseAction:PlayerAction?
        var replayAction:PlayerAction?
        
        let playButton:UIButton = {
            let button = UIButton()
            button.isHidden = true
            button.setImage(JNTool.image(name: "jn_player_play"), for: .normal)
            return button
        }()
        
        let pauseButton:UIButton = {
            let button = UIButton()
            button.setImage(JNTool.image(name: "jn_player_pause"), for: .normal)
            button.isHidden = true
            return button
        }()
        
        let replayButton: UIButton = {
            let button = UIButton()
            button.setImage(JNTool.image(name: "jn_player_play"), for: .normal)
            button.isHidden = true
            return button
        }()
        
        let loadingView:UIActivityIndicatorView = {
            let indicator = UIActivityIndicatorView()
            indicator.hidesWhenStopped = true
            indicator.color = UIColor.white
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
            self.backgroundColor = UIColor.clear
            
            [self.pauseButton, self.playButton, self.replayButton,self.loadingView].forEach({[unowned self] item in
                item.translatesAutoresizingMaskIntoConstraints = false
                self.addSubview(item)
                let width = NSLayoutConstraint(item: item, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 60)
                let height = NSLayoutConstraint(item: item, attribute: .height, relatedBy: .equal, toItem: item, attribute: .width, multiplier: 1, constant: 0)
                item.addConstraints([width, height])
            })
            
            self.addConstraints({[unowned self] in
                
                let width = NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 40)
                let height = NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 1, constant: 0)
                
                var constArr:[NSLayoutConstraint] = []
                for item in [self.playButton, self.pauseButton, self.loadingView, self.replayButton]{
                    let centerX = NSLayoutConstraint(item: item, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0)
                    let centerY = NSLayoutConstraint(item: item, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0)
                    constArr.append(centerX)
                    constArr.append(centerY)
                }
                
                return [width, height] + constArr
            }())

            
            self.loadingView.startAnimating()
            
            self.layoutIfNeeded()
        }
        
        func setUpAction(){
            [self.playButton, self.pauseButton, self.replayButton].forEach({[unowned self] in $0.addTarget(self, action: #selector(self.playAction(sender:)), for: .touchUpInside)})
        }
        
        func playAction(sender:UIButton){
            sender.isHidden = true
            
            switch sender {
            case self.playButton:
                self.playAction?()
                self.pauseButton.isHidden = false
            case self.pauseButton:
                self.pauseAction?()
                self.playButton.isHidden = false
            case self.replayButton:
                self.replayAction?()
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
        
        var sliderValueChangedAction:((_ value:Float) -> Void)?
        
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
        
        let backgroundView:UIView = {
            let view = UIView()
            view.backgroundColor = UIColor.black
            view.alpha = 0.5
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()
        
        fileprivate let totalTimeLabel:UILabel = {
            let label = UILabel()
            label.textColor = UIColor.white
            label.font = UIFont.systemFont(ofSize: 12)
            label.text = "00:00"
            return label
        }()
        
        fileprivate let playedTimeLabel:UILabel = {
            let label = UILabel()
            label.textColor = UIColor.white
            label.font = UIFont.systemFont(ofSize: 12)
            label.text = "00:00"
            return label
        }()
        
        let fullScreenButton: UIButton = {
            let button = UIButton()
            button.setImage(JNTool.image(name: "jn_player_full_screen"), for: .normal)
            return button
        }()
        
        let nonFullScreenButton: UIButton = {
            let button = UIButton()
            button.setImage(JNTool.image(name: "jn_player_nonfull_screen"), for: .normal)
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
            self.backgroundColor = UIColor.clear
            
            self.addSubview(self.backgroundView)
            
            self.addConstraint({[unowned self] in
                let height = NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 40)
                return height
            }())
            
            [self.processView, self.totalTimeLabel, self.playedTimeLabel,self.fullScreenButton, self.nonFullScreenButton].forEach({[unowned self] in
                
                $0.translatesAutoresizingMaskIntoConstraints = false
                self.addSubview($0)
                
            })
            
            [self.fullScreenButton, self.nonFullScreenButton].forEach({item in
                let height = NSLayoutConstraint(item: item, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 30)
                let width = NSLayoutConstraint(item: item, attribute: .width, relatedBy: .equal, toItem: item, attribute: .height, multiplier: 1, constant: 0)
                item.addConstraints([height, width])
            })
            
            self.addConstraints({[unowned self] in
                
                let backgroundCons = JNTool.edges(first: self.backgroundView, second: self)
                
                // Fullscreen button layout
                let fullRight = NSLayoutConstraint(item: self.fullScreenButton, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: -10)
                let fullCenterY = NSLayoutConstraint(item: self.fullScreenButton, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0)
                
                // NonFullscreen button layout
                let nonFullRight = NSLayoutConstraint(item: self.nonFullScreenButton, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: -10)
                let nonFullCenterY = NSLayoutConstraint(item: self.nonFullScreenButton, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0)
                
                // PlayedTimeLabel layout
                let playedLeft = NSLayoutConstraint(item: self.playedTimeLabel, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 10)
                let playedCenterY = NSLayoutConstraint(item: self.playedTimeLabel, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0)
                
                // TotalTimeLabel layout
                let totalRight = NSLayoutConstraint(item: self.totalTimeLabel, attribute: .right, relatedBy: .equal, toItem: self.fullScreenButton, attribute: .left, multiplier: 1, constant: -10)
                let totalCenterY = NSLayoutConstraint(item: self.totalTimeLabel, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0)
                
                // Progressview layout
                let progressLeft = NSLayoutConstraint(item: self.processView, attribute: .left, relatedBy: .equal, toItem: self.playedTimeLabel, attribute: .right, multiplier: 1, constant: 5)
                let progressTop = NSLayoutConstraint(item: self.processView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0)
                let progressRight = NSLayoutConstraint(item: self.processView, attribute: .right, relatedBy: .equal, toItem: self.totalTimeLabel, attribute: .left, multiplier: 1, constant: -5)
                let progressBottom = NSLayoutConstraint(item: self.processView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0)
                
                return [fullRight, fullCenterY, nonFullRight, nonFullCenterY, playedLeft, playedCenterY, totalRight, totalCenterY, progressLeft, progressTop, progressRight, progressBottom] + backgroundCons
            }())
            
            if JNTool.deviceIsHorizontal(){
                self.nonFullScreenButton.isHidden = false
                self.fullScreenButton.isHidden = true
            }else{
                self.nonFullScreenButton.isHidden = true
                self.fullScreenButton.isHidden = false
            }
            
            self.layoutIfNeeded()
        }
        
        func setUpAction(){
            [self.fullScreenButton, self.nonFullScreenButton].forEach({[unowned self] in
                $0.addTarget(self, action: #selector(self.playActions(sender:)), for: .touchUpInside)
            })
            
            // Slider Action
            self.processView.slider.addTarget(self, action: #selector(self.sliderActionEnd(sender:event:)), for: [.touchUpInside, .touchCancel, .touchUpOutside])
            self.processView.slider.addTarget(self, action: #selector(self.sliderActionBegin(sender:event:)), for: .touchDown)
            self.processView.slider.addTarget(self, action: #selector(self.sliderActionValueChanged(sender:event:)), for: .valueChanged)
            
            NotificationCenter.default.addObserver(self, selector: #selector(self.screenOrientionChanged(notification:)), name: NSNotification.Name.UIApplicationDidChangeStatusBarOrientation, object: nil)
        }
        
        func screenOrientionChanged(notification:NSNotification){
            if JNTool.deviceIsHorizontal(){
                self.nonFullScreenButton.isHidden = false
                self.fullScreenButton.isHidden = true
            }else{
                self.nonFullScreenButton.isHidden = true
                self.fullScreenButton.isHidden = false
            }
        }
        
        func playActions(sender:UIButton){
            switch sender {
            case self.fullScreenButton:
                self.fullScreenAction?()
                
            case self.nonFullScreenButton:
                self.nonFullScreenAction?()
                
            default:
                print("")
            }
        }
        
        func sliderActionEnd(sender:UISlider, event:UIControlEvents){
            print(#function)
        }
        
        func sliderActionBegin(sender:UISlider, event:UIControlEvents){
            print(#function)
        }
        
        func sliderActionValueChanged(sender:UISlider, event:UIControlEvents){
            self.sliderValueChangedAction?(sender.value)
        }
        
        deinit{
            NotificationCenter.default.removeObserver(self)
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
                pro.tintColor = UIColor.white
                pro.trackTintColor = UIColor.gray
                pro.translatesAutoresizingMaskIntoConstraints = false
                return pro
            }()
            
            let slider:JNSlider = {
                let slider = JNSlider()
                slider.translatesAutoresizingMaskIntoConstraints = false
                slider.minimumTrackTintColor = UIColor(red: 255 / 255, green: 206 / 255, blue: 88 / 255, alpha: 1)
                slider.maximumTrackTintColor = UIColor.clear
                slider.setThumbImage(JNTool.image(name: "jn_player_slider_thumb"), for: .normal)
                return slider
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
                self.backgroundColor = UIColor.clear
                self.translatesAutoresizingMaskIntoConstraints = false
                
                self.addSubview(self.progressView)
                self.addSubview(self.slider)
                
                let progressHeight = NSLayoutConstraint(item: self.progressView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 3)
                self.progressView.addConstraint(progressHeight)

                let sliderHeight = NSLayoutConstraint(item: self.slider, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 30)
                self.slider.addConstraint(sliderHeight)
                
                self.addConstraints({[unowned self] in
                    // Progress layout
                    let progressLeft = NSLayoutConstraint(item: self.progressView, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 0)
                    let progressRight = NSLayoutConstraint(item: self.progressView, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: 0)
                    let progressCenterY = NSLayoutConstraint(item: self.progressView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 1)
                    
                    // Slider layout
                    let sliderLeft = NSLayoutConstraint(item: self.slider, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 0)
                    let sliderRight = NSLayoutConstraint(item: self.slider, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: 0)
                    let sliderCenterY = NSLayoutConstraint(item: self.slider, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0)
                    
                    return [progressLeft, progressRight, progressCenterY, sliderLeft, sliderRight, sliderCenterY]
                }())
                
            }
            
            func setUpAction(){
                
            }
            
            class JNSlider:UISlider{
                override func trackRect(forBounds bounds: CGRect) -> CGRect {
                    let rect = super.trackRect(forBounds: bounds)
                    
                    return CGRect(origin: rect.origin, size: CGSize(width: rect.width, height: 3.5))
                }
                
                override func thumbRect(forBounds bounds: CGRect, trackRect rect: CGRect, value: Float) -> CGRect {
                    let thumbRect = super.thumbRect(forBounds: bounds, trackRect: rect, value: value)
                    return thumbRect
                }
            }
        }
    }
}

extension JNPlayerControlView{
    func closeLoading() {
        self.middleControl.closeLoading()
    }
    
    func showLoading(){
        self.middleControl.loadingView.startAnimating()
    }
}
