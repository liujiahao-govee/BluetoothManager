//
//  BMError.swift
//  BluetoothManager
//
//  Created by 刘嘉豪 on 2020/11/16.
//

import Foundation

public struct BMErrorMsg {
    static var didDiscoverServicesFailed: String?
    static var didDiscoverCharacteristicsFailed: String?
    static var didUpdateValueFailed: String?
}

public enum BMError: Error {
    /// 发现服务报错
    case didDiscoverServicesFailed(_ device: BluetoothDeviceModel, errorMsg: String?)
    /// 发现特征报错
    case didDiscoverCharacteristicsFailed(_ device: BluetoothDeviceModel, service: String, errorMsg: String?)
    /// 通知数据报错
    case didUpdateValueFailed(_ device: BluetoothDeviceModel, characteristic: String, errorMsg: String?)
}
