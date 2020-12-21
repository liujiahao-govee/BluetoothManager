//
//  BluetoothManagerDelegate.swift
//  BluetoothManager
//
//  Created by 刘嘉豪 on 2020/11/16.
//

import Foundation
import CoreBluetooth

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
    
    /// 发现设备
    /// - Parameters:
    ///   - device: 新发现的设备
    ///   - devices: 全部发现的设备
    func didDiscover(device: BluetoothDeviceModel, devices: [BluetoothDeviceModel])
    
    /// 连接设备成功
    /// - Parameter device: 被连接的设备
    /// - discover 设备的服务和特征并设置通知的特征
    func didConnect(device: BluetoothDeviceModel)
    
    /// 连接设备失败
    /// - Parameters:
    ///   - deviceName: 设备名
    ///   - errorMsg: 错误消息
    func didFailToConnect(deviceName: String?, errorMsg: String?)
    
    /// 设备断开连接
    /// - Parameters:
    ///   - device: 断连的设备
    ///   - errorMsg: 错误消息（如果主动断开，则为nil）
    func didDisconnect(device: BluetoothDeviceModel, errorMsg: String?)
    
    /// 设备发现服务和特征完毕，可以发送数据
    /// - Parameter device: 设备
    func didReady(device: BluetoothDeviceModel)
    
    /// 接收到设备通知的数据
    /// - Parameters:
    ///   - device: 设备
    ///   - characteristic: 特征
    ///   - data: 数据
    func didUpdateValue(device: BluetoothDeviceModel, characteristic: String, data: Data)
    
    /// 设备数据更新（扫描到已发现的设备和读取RSSI调用）
    /// - Parameter device: 设备
    func didUpdateDevice(_ device: BluetoothDeviceModel)
    
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
    func didUpdateDevice(_ device: BluetoothDeviceModel) {}
    func didCatchError(_ error: BMError) {}
}
