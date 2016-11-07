//
//  ViewController.swift
//  Example
//
//  Created by mac on 16/10/12.
//  Copyright © 2016年 Magugi. All rights reserved.
//

import UIKit
import JNPlayerKit

class ViewController: UIViewController {

    let topPlayerView:JNPlayerView = JNPlayerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setUpTopPlayer()
        
        self.topPlayerView.delegate = self
        
        //self.topPlayerView.play("http://od7vwyosd.bkt.clouddn.com/o_1asev3gvokag1bqb1ohqg6h1ko29.mp4", title: "TopPlayerView")
        
        self.topPlayerView.play([("http://baobab.wdjcdn.com/1457162012752491010143.mp4", "firstAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"), ("http://baobab.wdjcdn.com/14571455324031.mp4", "second"), ("http://gslb.miaopai.com/stream/kPzSuadRd2ipEo82jk9~sA__.mp4", "third")])
        
        self.topPlayerView.backAction = {
            self.navigationController?.popViewControllerAnimated(true)
        }
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        //self.bottomPlayerView.play(NSURL(string: "http://gslb.miaopai.com/stream/kPzSuadRd2ipEo82jk9~sA__.mp4")!, title: "BottomPlayerView")
        
    }
    
    var bottomConstraint:NSLayoutConstraint?
    var heightConstraint:NSLayoutConstraint?
    
    func setUpTopPlayer(){
        self.view.addSubview(self.topPlayerView)
        
        self.view.addConstraints({
            
            let left = NSLayoutConstraint(item: self.topPlayerView, attribute: .Left, relatedBy: .Equal, toItem: self.view, attribute: .Left, multiplier: 1, constant: 0)
            let top = NSLayoutConstraint(item: self.topPlayerView, attribute: .Top, relatedBy: .Equal, toItem: self.view, attribute: .Top, multiplier: 1, constant: 0)
            let right = NSLayoutConstraint(item: self.topPlayerView, attribute: .Right, relatedBy: .Equal, toItem: self.view, attribute: .Right, multiplier: 1, constant: 0)
            
            let bottom = NSLayoutConstraint(item: self.topPlayerView, attribute: .Bottom, relatedBy: .Equal, toItem: self.view, attribute: .Bottom, multiplier: 1, constant: 0)
            
            self.bottomConstraint = bottom
            
            return [left, top, right, bottom]}()
        )
        
        
        self.topPlayerView.addConstraint({
            let height = NSLayoutConstraint(item: self.topPlayerView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 200)
            self.heightConstraint = height
            return height
        }())
        
        let isPartrait = self.view.frame.width < self.view.frame.height
        self.bottomConstraint?.active = !isPartrait
        self.heightConstraint?.active = isPartrait
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.topPlayerView.play(nil)
    }
    
}

extension ViewController: JNPlayerViewDelegate{
    // 当前正在播放的视频, 该方法会在加载视频时执行
    func playerView(player:JNPlayerView, playingItem:JNPlayerItem, index:Int){
        print("playingItem:\(playingItem)  index:\(index)")
    }
    
    // 播放完成的视频, 该方法会在视频播放完成时执行
    func playerView(player:JNPlayerView, playEndItem:JNPlayerItem){
        print("playedItme:\(playEndItem)")
    }
    
    // 返回按钮点击回调
    func playerViewBackAction(player:JNPlayerView){
        print("backAction")
    }
    
    // 播放失败
    func playerView(player:JNPlayerView, playingItem:JNPlayerItem, error:NSError){
        print("playerItemError:\(playingItem)")
    }
}

extension ViewController{
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return [.Portrait, .LandscapeLeft, .LandscapeRight]
    }
    
    override func preferredInterfaceOrientationForPresentation() -> UIInterfaceOrientation {
        return .Portrait
    }
    
    override func prefersStatusBarHidden() -> Bool {
        if self.view.frame.width > self.view.frame.height{
            return true
        }else{
            return false
        }
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        
        coordinator.animateAlongsideTransition({ (context) in
            if size.width > size.height{
                self.bottomConstraint?.active = true
                self.heightConstraint?.active = false
                self.view.layoutIfNeeded()
            }else{
                self.bottomConstraint?.active = false
                self.heightConstraint?.active = true
                self.view.layoutIfNeeded()
            }
        }, completion: {content in
        
        })
    }
}


