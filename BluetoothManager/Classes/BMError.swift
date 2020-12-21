//
//  BMError.swift
//  BluetoothManager
//
//  Created by 刘嘉豪 on 2020/11/16.
//

import Foundation

public struct BMErrorMsg {
    static var didDiscoverServicesError: String?
    static var didDiscoverCharacteristicsError: String?
    static var didUpdateValueError: String?
    static var didReadRSSIError: String?
}

public enum BMError: Error {
    /// 发现服务报错
    case didDiscoverServicesError(_ device: BluetoothDeviceModel, errorMsg: String?)
    /// 发现特征报错
    case didDiscoverCharacteristicsError(_ device: BluetoothDeviceModel, service: String, errorMsg: String?)
    /// 通知数据报错
    case didUpdateValueError(_ device: BluetoothDeviceModel, characteristic: String, errorMsg: String?)
    /// 读取RSSI报错
    case didReadRSSIError(_ device: BluetoothDeviceModel, errorMsg: String?)
}
