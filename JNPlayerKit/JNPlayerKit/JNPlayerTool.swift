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
        
        let podBundle = NSBundle(forClass: self.classForCoder)
        
        if let bundleURL = podBundle.URLForResource("JNPlayerKit", withExtension: "bundle") {
            if let bundle = NSBundle(URL: bundleURL) {
                let image = UIImage(named: name, inBundle: bundle, compatibleWithTraitCollection: nil)
                return image
            }
            
        }
        
        let bundle = NSBundle(forClass: self.classForCoder)
        let image = UIImage(named: name, inBundle: bundle, compatibleWithTraitCollection: nil)
        return image
    }
    
    func imageWithImage(image: UIImage?, scaledToSize newSize: CGSize) -> UIImage?
    {
        guard image != nil else{return nil}
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        image!.drawInRect(CGRectMake(0, 0, newSize.width, newSize.height))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    func edges(first:UIView, second:UIView) -> [NSLayoutConstraint]{
        
        let left = NSLayoutConstraint(item: first, attribute: .Left, relatedBy: .Equal, toItem: second, attribute: .Left, multiplier: 1, constant: 0)
        let top = NSLayoutConstraint(item: first, attribute: .Top, relatedBy: .Equal, toItem: second, attribute: .Top, multiplier: 1, constant: 0)
        let right = NSLayoutConstraint(item: first, attribute: .Right, relatedBy: .Equal, toItem: second, attribute: .Right, multiplier: 1, constant: 0)
        let bottom = NSLayoutConstraint(item: first, attribute: .Bottom, relatedBy: .Equal, toItem: second, attribute: .Bottom, multiplier: 1, constant: 0)
    
        return [left, top, right, bottom]
    }
    
    // 当前设备是否为横屏
    func deviceIsHorizontal() -> Bool{
        let currentOrient = UIApplication.sharedApplication().statusBarOrientation
        if currentOrient == .LandscapeRight || currentOrient == .LandscapeLeft{
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
    private var cache:[String: (CMTime, NSTimeInterval)] = [:]
    
    subscript(key: String) -> CMTime?{
        get{
            return self.cache[key]?.0 ?? kCMTimeZero
        }
        set{
            if self.cache.count > 20{
                var lock = OS_SPINLOCK_INIT
                OSSpinLockLock(&lock)
                
                self.cache.sort({ $0.1.1 < $1.1.1}).map({$0.0})[0...4].forEach({[unowned self] key in
                    self.cache.removeValueForKey(key)
                    })
                
                OSSpinLockUnlock(&lock)
            }
            if let _ = newValue{
                self.cache[key] = (newValue!, NSDate().timeIntervalSince1970)
            }else{
                self.cache.removeValueForKey(key)
            }
        }
    }
}
