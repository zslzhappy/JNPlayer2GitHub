//
//  JNPlayerNetworkMonitor.swift
//  JNPlayerKit
//
//  Created by mac on 2016/11/16.
//  Copyright © 2016年 Magugi. All rights reserved.
//

import Foundation
import Dispatch


/// 网络状态
///
/// - wifi:
/// - g2: 2G
/// - g3: 3G
/// - g4: 4G
/// - unknow: 未知状态
public enum NetworkStatus:Int {
    case wifi = 1
    case g2 = 2
    case g3 = 3
    case g4 = 4
    case unknow
}


/// 获取网络状态的回调
public typealias JNPlayerNetworkStatusHandler = () -> NetworkStatus


/// 播放器网络监听器
public class JNPlayerNetworkMonitor:NSObject{
    
    /// 单例
    public static let monitor:JNPlayerNetworkMonitor = JNPlayerNetworkMonitor()
    
    private override init(){
        super.init()
    }
    
    /// 获取当前网络状态的回调
    public var currentStatusHandler:JNPlayerNetworkStatusHandler? = nil
    
    /// 获取之前网络状态的回调
    public var preStatusHandler:JNPlayerNetworkStatusHandler? = nil
    
    
    /// 网络状态切换时执行该方法
    ///
    /// - Parameter status: NetworkStatus
    public func statusChanged(status:NetworkStatus){
        NotificationCenter.default.post(name: NSNotification.Name.JNPlayerNetworkChanged, object: nil, userInfo: ["status":status])
    }
    
    
    /// 前网络状态
    ///
    /// - Returns: NetworkStatus
    internal func preStatus() -> NetworkStatus{
        return self.preStatusHandler?() ?? .wifi
    }
    
    
    /// 当前网络状态
    /// 注: 会阻塞当前线程
    ///
    /// - Returns: NetworkStatus/nil
    internal func currentStatus() -> NetworkStatus?{
        return currentStatusHandler?()
    }
}

extension NSNotification.Name{
    /// JNPlayerKit网络状态切换通知
    static let JNPlayerNetworkChanged = NSNotification.Name("JNPlayerKit_JNPlayerNetworkChanged")
}
