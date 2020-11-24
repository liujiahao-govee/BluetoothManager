//
//  BluetoothDelegate.swift
//  WidgetDemo
//
//  Created by 刘嘉豪 on 2020/11/17.
//

import Foundation
import CoreBluetooth

class BluetoothDelegate: NSObject {
    
    var didUpdateState: ((_ state: CBCentralManagerState) -> Void)?
    
    var didDiscover: ((_ device: BluetoothDeviceModel, _ devices: [BluetoothDeviceModel]) -> Void)?
    
    override init() {
        super.init()
        
        BluetoothManager.shared.addDelegate(self)
    }
}

extension BluetoothDelegate: BluetoothManagerDelegate {
    
    func didUpdateState(state: CBCentralManagerState) {
        print(#function, state)
    }
    
    func didDiscover(device: BluetoothDeviceModel, devices: [BluetoothDeviceModel]) {
        print(#function, device, devices.count)
    }
    
    func didConnect(device: BluetoothDeviceModel) {}
    
    func didFailToConnect(deviceName: String?, errorMsg: String?) {}
    
    func didDisconnect(device: BluetoothDeviceModel, errorMsg: String?) {}
    
    func didReady(device: BluetoothDeviceModel) {}
    
    func didUpdateValue(device: BluetoothDeviceModel, characteristic: String, data: Data) {}
    
    func didCatchError(_ error: BMError) {}
}

