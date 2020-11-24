//
//  BluetoothManagerDelegate.swift
//  TestBluetoothKit
//
//  Created by 刘嘉豪 on 2020/11/16.
//

import Foundation
import CoreBluetooth

// MARK: - BluetoothManagerDelegate

public protocol BluetoothManagerDelegate: NSObject {
    
    /// 蓝牙状态更新
    /// - Parameter state: 蓝牙状态
    /// - poweredOn -> startScan()
    @available(iOS, introduced: 5.0, deprecated: 10.0, message: "Use CBManagerState instead")
    func didUpdateState(state: CBCentralManagerState)
    
    /// 蓝牙状态更新
    /// - Parameter state: 蓝牙状态
    /// - poweredOn -> startScan()
    @available(iOS 10.0, *)
    func didUpdateState(state: CBManagerState)
    
    /// 发现外设
    /// - Parameters:
    ///   - device: 新发现的外设
    ///   - deivces: 全部发现的外设
    func didDiscover(device: BluetoothDeviceModel, devices: [BluetoothDeviceModel])
    
    /// 连接外设成功
    /// - Parameter device: 被连接的外设
    /// - discover 外设的服务和特征并设置通知的特征
    func didConnect(device: BluetoothDeviceModel)
    
    /// 连接外设失败
    /// - Parameters:
    ///   - deviceName: 外设名
    ///   - errorMsg: 错误消息
    func didFailToConnect(deviceName: String?, errorMsg: String?)
    
    /// 外设断开连接
    /// - Parameters:
    ///   - device: 断连的外设
    ///   - errorMsg: 错误消息
    func didDisconnect(device: BluetoothDeviceModel, errorMsg: String?)
    
    /// 外设发现服务和特征完毕，可以发送数据
    /// - Parameter device: 外设
    func didReady(device: BluetoothDeviceModel)
    
    /// 接收到外设通知的数据
    /// - Parameters:
    ///   - device: 外设
    ///   - characteristic: 特征
    ///   - data: 数据
    func didUpdateValue(device: BluetoothDeviceModel, characteristic: String, data: Data)
    
    /// 出现了错误
    /// - Parameter error: 错误
    func didCatchError(_ error: BMError)
}

public extension BluetoothManagerDelegate {
    @available(iOS, introduced: 5.0, deprecated: 10.0, message: "Use CBManagerState instead")
    func didUpdateState(state: CBCentralManagerState) {}
    @available(iOS 10.0, *)
    func didUpdateState(state: CBManagerState) {}
    func didDiscover(device: BluetoothDeviceModel, devices: [BluetoothDeviceModel]) {}
    func didConnect(device: BluetoothDeviceModel) {}
    func didFailToConnect(deviceName: String?, errorMsg: String?) {}
    func didDisconnect(device: BluetoothDeviceModel, errorMsg: String?) {}
    func didReady(device: BluetoothDeviceModel) {}
    func didUpdateValue(device: BluetoothDeviceModel, characteristic: String, data: Data) {}
    func didCatchError(_ error: BMError) {}
}
