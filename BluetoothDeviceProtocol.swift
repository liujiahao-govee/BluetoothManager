//
//  DeviceProtocol.swift
//  BluetoothManager
//
//  Created by 刘嘉豪 on 2020/12/14.
//

import Foundation
import CoreBluetooth

/// [服务: [特征]]
public typealias ServiceCharacteristicsDict = [String: [String]]
/// (设备, 特征, 数据)
public typealias WriteableDataTuple = (device: BluetoothDeviceProtocol, characteristic: String, data: Data)
/// (服务, 读特征, 写特征)
public typealias ServiceReadWriteUUIDTuple = (service: String, read: String, write: String)

// MARK: - 蓝牙设备模型协议

public protocol BluetoothDeviceProtocol {
    /// 设备（扫描发现的）
    var underlyingDevice: BluetoothDeviceModel? { get set }
    /// 服务、读、写 uuids
    var uuidTuple: ServiceReadWriteUUIDTuple { get }
    /// 需要通知的特征
    var notifyCharacteristics: Set<String> { get }
    /// OTA 服务、读、写 uuids
    var otaUuidTuple: ServiceReadWriteUUIDTuple? { get }
    /// 心跳数据包
    var heartbeatData: Data? { get }
    /// 服务: [特征]
    var serviceCharacteristics: ServiceCharacteristicsDict { get }
    /// 外设服务
    var services: Set<String> { get }
    /// 外设特征
    var characteristics: Set<String> { get }
    /// 读特征
    var readCharacteristic: CBCharacteristic? { get }
    /// 写特征
    var writeCharacteristic: CBCharacteristic? { get }
    /// OTA读特征
    var otaReadCharacteristic: CBCharacteristic? { get }
    /// OTA写特征
    var otaWriteCharacteristic: CBCharacteristic? { get }
    /// 外设是否准备完毕（服务和特征都已匹配）
    var isReady: Bool { get }
    /// 根据uuid获取已发现的特征
    /// - Parameter uuidStr: 特征uuid
    /// - Returns: 发现的特征
    func getDisCoveredCharacteristic(_ uuidStr: String) -> CBCharacteristic?
}

public extension BluetoothDeviceProtocol {
    
    var notifyCharacteristics: Set<String> {
        otaUuidTuple == nil ?
            [uuidTuple.read] :
            [uuidTuple.read, otaUuidTuple!.read]
    }
    
    var otaUuidTuple: ServiceReadWriteUUIDTuple? { nil }
    
    var heartbeatData: Data? { nil }
    
    var serviceCharacteristics: ServiceCharacteristicsDict {
        var dict = ServiceCharacteristicsDict()
        dict[uuidTuple.service] = [uuidTuple.read, uuidTuple.write]
        if let otaUuidTuple = otaUuidTuple {
            dict[otaUuidTuple.service] = [otaUuidTuple.read, otaUuidTuple.write]
        }
        return dict
    }
    
    var services: Set<String> {
        Set(serviceCharacteristics.keys.map { $0.description })
    }
    
    var characteristics: Set<String> {
        Set(serviceCharacteristics.values.flatMap { $0 })
    }
    
    var readCharacteristic: CBCharacteristic? {
        getDisCoveredCharacteristic(uuidTuple.read)
    }
    
    var writeCharacteristic: CBCharacteristic? {
        getDisCoveredCharacteristic(uuidTuple.write)
    }
    
    var otaReadCharacteristic: CBCharacteristic? {
        guard let uuid = otaUuidTuple?.read else { return nil }
        return getDisCoveredCharacteristic(uuid)
    }
    
    var otaWriteCharacteristic: CBCharacteristic? {
        guard let uuid = otaUuidTuple?.write else { return nil }
        return getDisCoveredCharacteristic(uuid)
    }
    
    var isReady: Bool {
        guard let disCoveredCharacteristics = underlyingDevice?.disCoveredCharacteristics else { return false }
        return characteristics.isSubset(of: disCoveredCharacteristics.map({ $0.uuidString }))
    }
    
    func getDisCoveredCharacteristic(_ uuidStr: String) -> CBCharacteristic? {
        underlyingDevice?.getDisCoveredCharacteristic(uuidStr)
    }
}
