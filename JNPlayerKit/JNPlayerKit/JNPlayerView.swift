//
//  JNPlayerView.swift
//  JNPlayerKit
//
//  Created by mac on 16/10/12.
//  Copyright © 2016年 Magugi. All rights reserved.
//

import UIKit
import AVFoundation

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
        self.addConstraints({
            let left = NSLayoutConstraint(item: self.player, attribute: .Left, relatedBy: .Equal, toItem: self, attribute: .Left, multiplier: 1, constant: 0)
            let top = NSLayoutConstraint(item: self.player, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1, constant: 0)
            let right = NSLayoutConstraint(item: self.player, attribute: .Right, relatedBy: .Equal, toItem: self, attribute: .Right, multiplier: 1, constant: 0)
            let bottom = NSLayoutConstraint(item: self.player, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1, constant: 0)
            return [left, top, right, bottom]
        }())
        
        // PlayerControl
        self.addSubview(self.playerControl)
        self.addConstraints({
            let left = NSLayoutConstraint(item: self.playerControl, attribute: .Left, relatedBy: .Equal, toItem: self, attribute: .Left, multiplier: 1, constant: 0)
            let top = NSLayoutConstraint(item: self.playerControl, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1, constant: 0)
            let right = NSLayoutConstraint(item: self.playerControl, attribute: .Right, relatedBy: .Equal, toItem: self, attribute: .Right, multiplier: 1, constant: 0)
            let bottom = NSLayoutConstraint(item: self.playerControl, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1, constant: 0)
            return [left, top, right, bottom]
        }())
    }
}

public extension JNPlayerView{
    public func play(URL:NSURL, title:String? = nil){
        
    }
}

private class JNPlayer: UIView{

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
        self.backgroundColor = UIColor.redColor()
    }
    
    
}
