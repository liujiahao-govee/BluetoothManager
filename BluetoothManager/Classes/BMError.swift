//
//  BMError.swift
//  TestBluetoothKit
//
//  Created by 刘嘉豪 on 2020/11/16.
//

import Foundation

/// 用了这个，那么这个库暂时不考虑兼容OC
/// 如果后面需要改，那么要把BMError，继承NSError，然后errorCode是NSEnum，这样便可兼容

public enum BMError: Error {
    /// 发现服务报错
    case didDiscoverServicesFailed(_ device: BluetoothDeviceModel, error: Error)
    /// 发现特征报错
    case didDiscoverCharacteristicsFailed(_ device: BluetoothDeviceModel, service: String, error: Error)
    /// 通知数据报错
    case didUpdateValueFailed(_ device: BluetoothDeviceModel, characteristic: String, error: Error)
}

extension String: Error {}
