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

    @IBOutlet weak var bottomPlayerView: JNPlayerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setUpTopPlayer()
        
        
        self.topPlayerView.play(NSURL(string: "http://gslb.miaopai.com/stream/kPzSuadRd2ipEo82jk9~sA__.mp4")!, title: "TopPlayerView")
        
        self.bottomPlayerView.play(NSURL(string: "http://gslb.miaopai.com/stream/kPzSuadRd2ipEo82jk9~sA__.mp4")!, title: "BottomPlayerView")
        
    }
    
    func setUpTopPlayer(){
        self.view.addSubview(self.topPlayerView)
        
        self.view.addConstraints({
            
            let left = NSLayoutConstraint(item: self.topPlayerView, attribute: .Left, relatedBy: .Equal, toItem: self.view, attribute: .Left, multiplier: 1, constant: 0)
            let top = NSLayoutConstraint(item: self.topPlayerView, attribute: .Top, relatedBy: .Equal, toItem: self.view, attribute: .Top, multiplier: 1, constant: 0)
            let right = NSLayoutConstraint(item: self.topPlayerView, attribute: .Right, relatedBy: .Equal, toItem: self.view, attribute: .Right, multiplier: 1, constant: 0)
            
            return [left, top, right]}()
        )
        
        self.topPlayerView.addConstraint({
            return NSLayoutConstraint(item: self.topPlayerView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 200)
            }())
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        //self.topPlayerView.play()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

