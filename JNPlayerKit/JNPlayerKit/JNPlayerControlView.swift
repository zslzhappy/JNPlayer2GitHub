//
//  JNPlayerControlView.swift
//  JNPlayerKit
//
//  Created by mac on 16/10/12.
//  Copyright © 2016年 Magugi. All rights reserved.
//

import UIKit

protocol JNPlayerControlDelegate:JNPlayerControl {
    func jnPlayerTimes() -> (total: NSTimeInterval, current: NSTimeInterval)
    func jnPlayerSeekTime(time:NSTimeInterval)
    
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
    
    // ControlView 当前是否显示
    var isShow:Bool = true{
        didSet{
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
    
    var topControlTopConstraint:NSLayoutConstraint? = nil
    var bottomControlBottomContraint:NSLayoutConstraint? = nil
    
    func setUpUI(){
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = UIColor.clearColor()
        self.clipsToBounds = true
        
        [self.topControl, self.middleControl, self.bottomControl].forEach({self.addSubview($0)})
        
        // TopControl Layout
        self.addConstraints({[unowned self] in
            let left = NSLayoutConstraint(item: self.topControl, attribute: .Left, relatedBy: .Equal, toItem: self, attribute: .Left, multiplier: 1, constant: 0)
            
            let top = NSLayoutConstraint(item: self.topControl, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1, constant: 0)
            self.topControlTopConstraint = top
            
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
            self.bottomControlBottomContraint = bottom
            return [left, right, bottom]
        }())
        
        self.layoutIfNeeded()
    }
    
    func setUpAction(){
        
        self.topControl.backAction = {[unowned self] in self.delegate?.back()}
        
        self.middleControl.playAction = {[unowned self] in self.delegate?.play()}
        
        self.middleControl.pauseAction = {[unowned self] in self.delegate?.pause()}
        
        self.middleControl.replayAction = {[unowned self] in self.delegate?.play()}
        
        self.bottomControl.sliderValueChangedAction = {[unowned self] value in
            let totalTime = self.delegate?.jnPlayerTimes().total ?? 0
            
            let currentTime = totalTime * Double(value)
            
            self.currentTime = currentTime
            
            // player seek time
            self.delegate?.jnPlayerSeekTime(currentTime)
        }
        
        self.bottomControl.fullScreenAction = {[unowned self] in
            self.delegate?.jnPlayerFullScreen(true)
        }
        
        self.bottomControl.nonFullScreenAction = {[unowned self] in
            self.delegate?.jnPlayerFullScreen(false)
        }
        
        let tapGes = UITapGestureRecognizer(target: self, action: #selector(self.tapAction(_:)))
        self.addGestureRecognizer(tapGes)
    }
    
    func tapAction(tap:UITapGestureRecognizer){
        self.isShow = !self.isShow
    }
    
    func showControl(){
        
        UIView.animateWithDuration(0.35, delay: 0, options: .CurveEaseIn, animations: {
            
            // topControl
            self.topControlTopConstraint?.constant = 0
            self.topControl.alpha = 1
            
            // bottomControl
            self.bottomControlBottomContraint?.constant = 0
            self.bottomControl.alpha = 1
            
            // middleControl
            self.middleControl.alpha = 1
            
            self.layoutIfNeeded()
        }, completion: {completed in
            
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC * 3))
            
            dispatch_after(delayTime, dispatch_get_main_queue(), {[unowned self] in
                self.isShow = false
            })
        })
        
    }
    
    func hiddenControl(){
        UIView.animateWithDuration(0.35, delay: 0, options: .CurveEaseIn, animations: {
            
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
            view.backgroundColor = UIColor.clearColor()
            //view.alpha = 0.5
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()
        
        let backButton:UIButton = {
            let button = UIButton()
            button.setImage(JNTool.image("jn_player_top_back"), forState: .Normal)
            button.translatesAutoresizingMaskIntoConstraints = false
            return button
        }()
        
        let titleLabel:UILabel = {
            let lable = UILabel()
            lable.textColor = UIColor.whiteColor()
            lable.font = UIFont.systemFontOfSize(15)
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
            self.backgroundColor = UIColor.clearColor()
            
            self.addSubview(self.backgroundView)
            
            self.addSubview(self.backButton)
            self.addSubview(self.titleLabel)
            
            self.addConstraints({[unowned self] in
                let height = NSLayoutConstraint(item: self, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 64)
                
                let backgroundCons = JNTool.edges(self.backgroundView, second: self)
                
                // backButton layout
                let backLeft = NSLayoutConstraint(item: self.backButton, attribute: .Left, relatedBy: .Equal, toItem: self, attribute: .Left, multiplier: 1, constant: 10)
                let backCenterY = NSLayoutConstraint(item: self.backButton, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 10)
                
                // titleLabel layout
                let titleLeft = NSLayoutConstraint(item: self.titleLabel, attribute: .Left, relatedBy: .Equal, toItem: self.backButton, attribute: .Right, multiplier: 1, constant: 8)
                let titleCenterY = NSLayoutConstraint(item: self.titleLabel, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 10)
                
                return [height, backLeft, backCenterY, titleLeft, titleCenterY] + backgroundCons
            }())
            self.layoutIfNeeded()
        }
        
        func setUpAction(){
            self.backButton.addTarget(self, action: #selector(self.backAction(_:)), forControlEvents: .TouchUpInside)
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
                    self.pauseButton.hidden = true
                    self.playButton.hidden = false
                case .Play:
                    self.pauseButton.hidden = false
                    self.playButton.hidden = true
                case .PlayEnd:
                    self.pauseButton.hidden = true
                    self.playButton.hidden = true
                    self.replayButton.hidden = false
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
            button.hidden = true
            button.setImage(JNTool.image("jn_player_play"), forState: .Normal)
            return button
        }()
        
        let pauseButton:UIButton = {
            let button = UIButton()
            button.setImage(JNTool.image("jn_player_pause"), forState: .Normal)
            button.hidden = true
            return button
        }()
        
        let replayButton: UIButton = {
            let button = UIButton()
            button.setImage(JNTool.image("jn_player_play"), forState: .Normal)
            button.hidden = true
            return button
        }()
        
        let loadingView:UIActivityIndicatorView = {
            let indicator = UIActivityIndicatorView()
            indicator.hidesWhenStopped = true
            indicator.color = UIColor.whiteColor()
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
            
            [self.pauseButton, self.playButton, self.replayButton,self.loadingView].forEach({[unowned self] item in
                item.translatesAutoresizingMaskIntoConstraints = false
                self.addSubview(item)
                let width = NSLayoutConstraint(item: item, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 60)
                let height = NSLayoutConstraint(item: item, attribute: .Height, relatedBy: .Equal, toItem: item, attribute: .Width, multiplier: 1, constant: 0)
                item.addConstraints([width, height])
            })
            
            self.addConstraints({[unowned self] in
                
                let width = NSLayoutConstraint(item: self, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 40)
                let height = NSLayoutConstraint(item: self, attribute: .Height, relatedBy: .Equal, toItem: self, attribute: .Width, multiplier: 1, constant: 0)
                
                var constArr:[NSLayoutConstraint] = []
                for item in [self.playButton, self.pauseButton, self.loadingView, self.replayButton]{
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
            [self.playButton, self.pauseButton, self.replayButton].forEach({[unowned self] in $0.addTarget(self, action: #selector(self.playAction(_:)), forControlEvents: .TouchUpInside)})
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
        
        var sliderValueChangedAction:((value:Float) -> Void)?
        
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
            view.backgroundColor = UIColor.blackColor()
            view.alpha = 0.5
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()
        
        private let totalTimeLabel:UILabel = {
            let label = UILabel()
            label.textColor = UIColor.whiteColor()
            label.font = UIFont.systemFontOfSize(12)
            label.text = "00:00"
            return label
        }()
        
        private let playedTimeLabel:UILabel = {
            let label = UILabel()
            label.textColor = UIColor.whiteColor()
            label.font = UIFont.systemFontOfSize(12)
            label.text = "00:00"
            return label
        }()
        
        let fullScreenButton: UIButton = {
            let button = UIButton()
            button.setImage(JNTool.image("jn_player_full_screen"), forState: .Normal)
            return button
        }()
        
        let nonFullScreenButton: UIButton = {
            let button = UIButton()
            button.setImage(JNTool.image("jn_player_nonfull_screen"), forState: .Normal)
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
            self.backgroundColor = UIColor.clearColor()
            
            self.addSubview(self.backgroundView)
            
            self.addConstraint({[unowned self] in
                let height = NSLayoutConstraint(item: self, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 40)
                return height
            }())
            
            [self.processView, self.totalTimeLabel, self.playedTimeLabel,self.fullScreenButton, self.nonFullScreenButton].forEach({[unowned self] in
                
                $0.translatesAutoresizingMaskIntoConstraints = false
                self.addSubview($0)
                
            })
            
            [self.fullScreenButton, self.nonFullScreenButton].forEach({item in
                let height = NSLayoutConstraint(item: item, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 30)
                let width = NSLayoutConstraint(item: item, attribute: .Width, relatedBy: .Equal, toItem: item, attribute: .Height, multiplier: 1, constant: 0)
                item.addConstraints([height, width])
            })
            
            self.addConstraints({[unowned self] in
                
                let backgroundCons = JNTool.edges(self.backgroundView, second: self)
                
                // Fullscreen button layout
                let fullRight = NSLayoutConstraint(item: self.fullScreenButton, attribute: .Right, relatedBy: .Equal, toItem: self, attribute: .Right, multiplier: 1, constant: -10)
                let fullCenterY = NSLayoutConstraint(item: self.fullScreenButton, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 0)
                
                // NonFullscreen button layout
                let nonFullRight = NSLayoutConstraint(item: self.nonFullScreenButton, attribute: .Right, relatedBy: .Equal, toItem: self, attribute: .Right, multiplier: 1, constant: -10)
                let nonFullCenterY = NSLayoutConstraint(item: self.nonFullScreenButton, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 0)
                
                // PlayedTimeLabel layout
                let playedLeft = NSLayoutConstraint(item: self.playedTimeLabel, attribute: .Left, relatedBy: .Equal, toItem: self, attribute: .Left, multiplier: 1, constant: 10)
                let playedCenterY = NSLayoutConstraint(item: self.playedTimeLabel, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 0)
                
                // TotalTimeLabel layout
                let totalRight = NSLayoutConstraint(item: self.totalTimeLabel, attribute: .Right, relatedBy: .Equal, toItem: self.fullScreenButton, attribute: .Left, multiplier: 1, constant: -10)
                let totalCenterY = NSLayoutConstraint(item: self.totalTimeLabel, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 0)
                
                // Progressview layout
                let progressLeft = NSLayoutConstraint(item: self.processView, attribute: .Left, relatedBy: .Equal, toItem: self.playedTimeLabel, attribute: .Right, multiplier: 1, constant: 5)
                let progressTop = NSLayoutConstraint(item: self.processView, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1, constant: 0)
                let progressRight = NSLayoutConstraint(item: self.processView, attribute: .Right, relatedBy: .Equal, toItem: self.totalTimeLabel, attribute: .Left, multiplier: 1, constant: -5)
                let progressBottom = NSLayoutConstraint(item: self.processView, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1, constant: 0)
                
                return [fullRight, fullCenterY, nonFullRight, nonFullCenterY, playedLeft, playedCenterY, totalRight, totalCenterY, progressLeft, progressTop, progressRight, progressBottom] + backgroundCons
            }())
            
            
            let currentOrient = UIApplication.sharedApplication().statusBarOrientation
            
            switch currentOrient {
            case .LandscapeRight, .LandscapeLeft:
                self.nonFullScreenButton.hidden = false
                self.fullScreenButton.hidden = true
            case .Portrait:
                self.nonFullScreenButton.hidden = true
                self.fullScreenButton.hidden = false
            default:
                self.nonFullScreenButton.hidden = true
                self.fullScreenButton.hidden = false
            }
            
            self.layoutIfNeeded()
        }
        
        func setUpAction(){
            [self.fullScreenButton, self.nonFullScreenButton].forEach({[unowned self] in
                $0.addTarget(self, action: #selector(self.playActions(_:)), forControlEvents: .TouchUpInside)
            })
            
            // Slider Action
            self.processView.slider.addTarget(self, action: #selector(self.sliderActionEnd(_:event:)), forControlEvents: [.TouchUpInside, .TouchCancel, .TouchUpOutside])
            self.processView.slider.addTarget(self, action: #selector(self.sliderActionBegin(_:event:)), forControlEvents: .TouchDown)
            self.processView.slider.addTarget(self, action: #selector(self.sliderActionValueChanged(_:event:)), forControlEvents: .ValueChanged)
            
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.screenOrientionChanged(_:)), name: UIApplicationDidChangeStatusBarOrientationNotification, object: nil)
        }
        
        func screenOrientionChanged(notification:NSNotification){
            
            let orient = UIApplication.sharedApplication().statusBarOrientation
            
            switch orient {
            case .Portrait:
                self.nonFullScreenButton.hidden = true
                self.fullScreenButton.hidden = false
            case .LandscapeRight, .LandscapeLeft:
                self.nonFullScreenButton.hidden = false
                self.fullScreenButton.hidden = true
            default:
                print("")
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
            self.sliderValueChangedAction?(value:sender.value)
        }
        
        deinit{
            NSNotificationCenter.defaultCenter().removeObserver(self)
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
                pro.tintColor = UIColor.whiteColor()
                pro.trackTintColor = UIColor.grayColor()
                pro.translatesAutoresizingMaskIntoConstraints = false
                return pro
            }()
            
            let slider:JNSlider = {
                let slider = JNSlider()
                slider.translatesAutoresizingMaskIntoConstraints = false
                slider.minimumTrackTintColor = UIColor(red: 255 / 255, green: 206 / 255, blue: 88 / 255, alpha: 1)
                slider.maximumTrackTintColor = UIColor.clearColor()
                slider.setThumbImage(JNTool.image("jn_player_slider_thumb"), forState: .Normal)
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
                self.backgroundColor = UIColor.clearColor()
                self.translatesAutoresizingMaskIntoConstraints = false
                
                self.addSubview(self.progressView)
                self.addSubview(self.slider)
                
                let progressHeight = NSLayoutConstraint(item: self.progressView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 3)
                self.progressView.addConstraint(progressHeight)

                let sliderHeight = NSLayoutConstraint(item: self.slider, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 3)
                self.slider.addConstraint(sliderHeight)
                
                self.addConstraints({[unowned self] in
                    // Progress layout
                    let progressLeft = NSLayoutConstraint(item: self.progressView, attribute: .Left, relatedBy: .Equal, toItem: self, attribute: .Left, multiplier: 1, constant: 0)
                    let progressRight = NSLayoutConstraint(item: self.progressView, attribute: .Right, relatedBy: .Equal, toItem: self, attribute: .Right, multiplier: 1, constant: 0)
                    let progressCenterY = NSLayoutConstraint(item: self.progressView, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 1)
                    
                    // Slider layout
                    let sliderLeft = NSLayoutConstraint(item: self.slider, attribute: .Left, relatedBy: .Equal, toItem: self, attribute: .Left, multiplier: 1, constant: 0)
                    let sliderRight = NSLayoutConstraint(item: self.slider, attribute: .Right, relatedBy: .Equal, toItem: self, attribute: .Right, multiplier: 1, constant: 0)
                    let sliderCenterY = NSLayoutConstraint(item: self.slider, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 0)
                    
                    return [progressLeft, progressRight, progressCenterY, sliderLeft, sliderRight, sliderCenterY]
                }())
                
            }
            
            func setUpAction(){
                
            }
            
            class JNSlider:UISlider{
                override func trackRectForBounds(bounds: CGRect) -> CGRect {
                    let rect = super.trackRectForBounds(bounds)
                    
                    return CGRect(origin: rect.origin, size: CGSize(width: rect.width, height: 3.5))
                }
                
                override func thumbRectForBounds(bounds: CGRect, trackRect rect: CGRect, value: Float) -> CGRect {
                    let thumbRect = super.thumbRectForBounds(bounds, trackRect: rect, value: value)
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
}
