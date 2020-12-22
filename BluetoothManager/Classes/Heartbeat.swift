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
            
    private lazy var sourceTimer: DispatchSourceTimer = {
        let timer = DispatchSource.makeTimerSource(flags: .strict, queue: .global())
        timer.schedule(deadline: .now(), repeating: timeInterval)
        timer.setEventHandler { [weak self] in
            self?.beat()
        }
        return timer
    }()
    
    private let timeInterval: TimeInterval = 2
    
    public var devices: [BluetoothDeviceProtocol]
    
    public private(set) var isSuspended: Bool = true
    
    public init(_ manager: BluetoothManager, devices: [BluetoothDeviceProtocol]) {
        self.manager = manager
        self.devices = devices
    }
    
    deinit {
        cancel()
    }
}

public extension Heartbeat {
    
    func resume() {
        if isSuspended {
            sourceTimer.resume()
        }
        isSuspended = false
    }
    
    func suspend() {
        if isSuspended {
            return
        }
        isSuspended = true
        sourceTimer.suspend()
    }
    
    func cancel() {
        if sourceTimer.isCancelled {
            return
        }
        resume()// if timer isSuspended then crash!
        sourceTimer.cancel()
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
