//
//  JNPlayerControlView.swift
//  JNPlayerKit
//
//  Created by mac on 16/10/12.
//  Copyright © 2016年 Magugi. All rights reserved.
//

import UIKit

class JNPlayerControlView: UIView {
    
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
        self.backgroundColor = UIColor.blackColor()
        self.alpha = 0.3
    }

}
