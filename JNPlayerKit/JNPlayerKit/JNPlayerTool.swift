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
    
}

/**
 视频播放时间纪录，用于断点播放
 */
class JNPlayerCache: NSObject{
    static let sharedInstance = JNPlayerCache()
    private let cache:NSCache = {
        let cache = NSCache()
        cache.name = "JNPlayerCache"
        return cache
    }()
    
    subscript(key: String) -> CMTime?{
        get{
            if let value = self.cache.objectForKey(key) as? NSValue{
                return value.CMTimeValue
            }
            return kCMTimeZero
        }
        set{
            if let value = newValue{
                let timeValue = NSValue(CMTime:value)
                self.cache.setObject(timeValue, forKey: key)
            }else{
                self.cache.removeObjectForKey(key)
            }
        }
    }
    
}
