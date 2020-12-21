//
//  DeviceModel.swift
//  BluetoothManager_Example
//
//  Created by 刘嘉豪 on 2020/12/18.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import BluetoothManager

class DeviceModel: BluetoothDeviceProtocol {
    
    var name: String = ""
    
    var underlyingDevice: BluetoothDeviceModel?
    
    var uuidTuple: ServiceReadWriteUUIDTuple {
        (service: "00010203-0405-0607-0809-0A0B0C0D1910",
         read: "00010203-0405-0607-0809-0A0B0C0D2B10",
         write: "00010203-0405-0607-0809-0A0B0C0D2B11")
    }
    
    var heartbeatData: Data? {
        CommandEnum.getOn.data
    }
    
    init(name: String) {
        self.name = name
    }
}
