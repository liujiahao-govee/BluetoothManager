//
//  Heartbeat.swift
//  BluetoothManager
//
//  Created by 刘嘉豪 on 2020/11/24.
//

import Foundation

/// 心跳表[设备类型唯一标识: 心跳数据]
typealias HeartbeatDict = [String: Data]

class Heartbeat {
    
    init(_ manager: BluetoothManager) {
        self.manager = manager
    }
    
    unowned let manager: BluetoothManager
    
    var timer: Timer?
    
    var timeInterval: TimeInterval = 2
}

extension Heartbeat {
    
    func fire() {
//        RunLoop.current.add(Timer(), forMode: .common)
    }
}

private extension Heartbeat {
    
    
}
