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
            self.bottomControl.playerStatus = playerStatus
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
        
        self.bottomControl.playAction = {[unowned self] in self.delegate?.play()}
        
        self.bottomControl.pauseAction = {[unowned self] in self.delegate?.pause()}
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
            self.addConstraints({[unowned self] in
                let width = NSLayoutConstraint(item: self, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 40)
                let height = NSLayoutConstraint(item: self, attribute: .Height, relatedBy: .Equal, toItem: self, attribute: .Width, multiplier: 1, constant: 0)
                return [width, height]
            }())
            self.layoutIfNeeded()
        }
    }
    
    // MARK: 底部控制器
    class BottomControlView: UIView{
        
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
        var fullScreenAction:PlayerAction?
        var nonFullScreenAction:PlayerAction?
        
        let playButton:UIButton = {
            let button = UIButton()
            button.setTitle("播放", forState: .Normal)
            return button
        }()
        
        let pauseButton:UIButton = {
            let button = UIButton()
            button.setTitle("暂停", forState: .Normal)
            return button
        }()
        
        let processView:UIView = {
            let view = UIView()
            
            return view
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
            
            [self.playButton, self.pauseButton, self.processView, self.fullScreenButton, self.nonFullScreenButton].forEach({[unowned self] in
                
                $0.translatesAutoresizingMaskIntoConstraints = false
                self.addSubview($0)
                
            })
            
            self.addConstraints({[unowned self] in
                // Play button layout
                let playLeft = NSLayoutConstraint(item: self.playButton, attribute: .Left, relatedBy: .Equal, toItem: self, attribute: .Left, multiplier: 1, constant: 10)
                let playCenterY = NSLayoutConstraint(item: self.playButton, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 0)
                
                // Pause button layout
                let pauseLeft = NSLayoutConstraint(item: self.pauseButton, attribute: .Left, relatedBy: .Equal, toItem: self, attribute: .Left, multiplier: 1, constant: 10)
                let pauseCenterY = NSLayoutConstraint(item: self.pauseButton, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 0)
                
                // Fullscreen button layout
                let fullRight = NSLayoutConstraint(item: self.fullScreenButton, attribute: .Right, relatedBy: .Equal, toItem: self, attribute: .Right, multiplier: 1, constant: -10)
                let fullCenterY = NSLayoutConstraint(item: self.fullScreenButton, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 0)
                
                // NonFullscreen button layout
                let nonFullRight = NSLayoutConstraint(item: self.nonFullScreenButton, attribute: .Right, relatedBy: .Equal, toItem: self, attribute: .Right, multiplier: 1, constant: 0)
                let nonFullCenterY = NSLayoutConstraint(item: self.nonFullScreenButton, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 0)
                
                return [playLeft, playCenterY, pauseLeft, pauseCenterY, fullRight, fullCenterY, nonFullRight, nonFullCenterY]
            }())
            
            [self.playButton, self.pauseButton].forEach({item in
                let width = NSLayoutConstraint(item: item, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 20)
                let height = NSLayoutConstraint(item: item, attribute: .Height, relatedBy: .Equal, toItem: item, attribute: .Width, multiplier: 1, constant: 0)
                //item.addConstraints([width, height])
            })
            
            self.pauseButton.hidden = true
            self.nonFullScreenButton.hidden = true
            
            self.layoutIfNeeded()
        }
        
        func setUpAction(){
            [self.playButton, self.pauseButton, self.fullScreenButton, self.nonFullScreenButton].forEach({[unowned self] in
                $0.addTarget(self, action: #selector(self.playActions(_:)), forControlEvents: .TouchUpInside)
            })
        }
        
        func playActions(sender:UIButton){
            
            sender.hidden = true
            
            switch sender {
            case self.playButton:
                self.playAction?()
                self.pauseButton.hidden = false
            case self.pauseButton:
                self.pauseAction?()
                self.playButton.hidden = false
                
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
    }

}

extension JNPlayerControlView{
    
    func closeLoading() {
        self.middleControl.hidden = true
    }
}
