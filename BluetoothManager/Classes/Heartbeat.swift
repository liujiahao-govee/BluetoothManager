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
    
    weak var manager: BluetoothManager?
    
    var timer: Timer?
    
    var timeInterval: TimeInterval = 2
    
    init(_ manager: BluetoothManager) {
        self.manager = manager
    }
}

extension Heartbeat {
    
    func fire() {
        self.timer?.invalidate()
        let timer = Timer(timeInterval: timeInterval, target: self, selector: #selector(beat), userInfo: nil, repeats: true)
        RunLoop.current.add(timer, forMode: .common)
        self.timer = timer
    }
    
    func done() {
        self.timer?.invalidate()
        self.timer = nil
    }
}

private extension Heartbeat {
    
    @objc func beat() {
        /// write data
    }
}
