//
//  Heartbeat.swift
//  BluetoothManager
//
//  Created by 刘嘉豪 on 2020/11/24.
//

import Foundation
import CoreBluetooth

public final class Heartbeat {
    
    public weak var manager: BluetoothManager?
    
    private var timer: Timer?
    
    private let timeInterval: TimeInterval = 2
    
    var devices: [BluetoothDeviceProtocol]
    
    public init(_ manager: BluetoothManager, devices: [BluetoothDeviceProtocol]) {
        self.manager = manager
        self.devices = devices
    }
}

public extension Heartbeat {
    
    func fire() {
        self.timer?.invalidate()
        let timer = Timer(timeInterval: timeInterval, target: self, selector: #selector(beat), userInfo: nil, repeats: true)
        RunLoop.current.add(timer, forMode: .common)
        timer.fire()
        self.timer = timer
    }
    
    func done() {
        self.timer?.invalidate()
        self.timer = nil
    }
}

private extension Heartbeat {
    
    @objc func beat() {
        let tuples: [WriteableDataTuple] = devices.compactMap { (device) -> WriteableDataTuple? in
            guard device.underlyingDevice?.peripheral.state == .connected,
                  let data = device.heartbeatData else {
                return nil
            }
            return WriteableDataTuple(device, device.uuidTuple.write, data)
        }
        
        manager?.writeDatas(tuples)
    }
}
