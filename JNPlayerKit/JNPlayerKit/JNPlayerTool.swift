//
//  JNPlayerTool.swift
//  JNPlayerKit
//
//  Created by mac on 16/10/14.
//  Copyright © 2016年 Magugi. All rights reserved.
//

import UIKit
import AVFoundation

let JNTool = JNPlayerTool.sharedInstance

let JNCache = JNPlayerCache.sharedInstance

class JNPlayerTool:NSObject {
    
    static let sharedInstance = JNPlayerTool()
    
    func image(name:String) -> UIImage?{
        
        let podBundle = Bundle(for: self.classForCoder)
        
        if let bundleURL = podBundle.url(forResource: "JNPlayerKit", withExtension: "bundle") {
            if let bundle = Bundle(url: bundleURL) {
                let image = UIImage(named: name, in: bundle, compatibleWith: nil)
                return image
            }
            
        }
        
        let bundle = Bundle(for: self.classForCoder)
        let image = UIImage(named: name, in: bundle, compatibleWith: nil)
        return image
    }
    
    func imageWithImage(image: UIImage?, scaledToSize newSize: CGSize) -> UIImage?
    {
        guard image != nil else{return nil}
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        
        let frame = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        image!.draw(in: frame)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    func edges(first:UIView, second:UIView) -> [NSLayoutConstraint]{
        
        let left = NSLayoutConstraint(item: first, attribute: .left, relatedBy: .equal, toItem: second, attribute: .left, multiplier: 1, constant: 0)
        let top = NSLayoutConstraint(item: first, attribute: .top, relatedBy: .equal, toItem: second, attribute: .top, multiplier: 1, constant: 0)
        let right = NSLayoutConstraint(item: first, attribute: .right, relatedBy: .equal, toItem: second, attribute: .right, multiplier: 1, constant: 0)
        let bottom = NSLayoutConstraint(item: first, attribute: .bottom, relatedBy: .equal, toItem: second, attribute: .bottom, multiplier: 1, constant: 0)
    
        return [left, top, right, bottom]
    }
    
    // 当前设备是否为横屏
    func deviceIsHorizontal() -> Bool{
        let currentOrient = UIApplication.shared.statusBarOrientation
        if currentOrient == .landscapeRight || currentOrient == .landscapeLeft{
            return true
        }
        return false
    }
    
}

/**
 视频播放时间纪录，用于断点播放
 */
class JNPlayerCache: NSObject, NSCacheDelegate{
    static let sharedInstance = JNPlayerCache()
    private var cache:[String: (CMTime, TimeInterval)] = [:]
    
    subscript(key: String) -> CMTime?{
        get{
            return self.cache[key]?.0 ?? kCMTimeZero
        }
        set{
            if self.cache.count > 20{
                var lock = OS_SPINLOCK_INIT
                OSSpinLockLock(&lock)
                
                self.cache.sorted(by: { $0.1.1 < $1.1.1}).map({$0.0})[0...4].forEach({[unowned self] key in
                    self.cache.removeValue(forKey: key)
                    })
                
                OSSpinLockUnlock(&lock)
            }
            if let _ = newValue{
                self.cache[key] = (newValue!, NSDate().timeIntervalSince1970)
            }else{
                self.cache.removeValue(forKey: key)
            }
        }
    }
}
