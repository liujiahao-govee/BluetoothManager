//
//  DeviceProtocol.swift
//  BluetoothManager
//
//  Created by 刘嘉豪 on 2020/12/14.
//

import Foundation
import CoreBluetooth

// MARK: - 蓝牙设备模型协议

public protocol BluetoothDeviceProtocol: AnyObject, Equatable, CustomDebugStringConvertible {
    
    /// 外设
    var peripheral: CBPeripheral { get }
    /// 广播数据
    var advertisementData: [String : Any] { get set }
    /// 信号强度
    var rssi: Int { get set }
    
    /// 服务: [特征]
    var serviceCharacteristics: ServiceCharacteristicsDict { get set }
    /// 需要通知的特征
    var notifyCharacteristics: Set<String> { get set }
    /// 发现的特征
    var disCoveredCharacteristics: Set<CBCharacteristic> { get set }
    
    /// 外设名
    var name: String? { get }
    /// 外设uuid
    var uuid: String { get }
    /// 外设服务
    var services: Set<String> { get }
    /// 外设特征
    var characteristics: Set<String> { get }
    /// 外设是否准备完毕（服务和特征都已匹配）
    var isReady: Bool { get }
    
    /// 根据uuid获取已发现的特征
    /// - Parameter uuidStr: 特征uuid
    /// - Returns: 发现的特征
    func getDisCoveredCharacteristic(_ uuidStr: String) -> CBCharacteristic?
    
    /// 更新设备数据
    /// - Parameters:
    ///   - advertisementData: 广播数据
    ///   - rssi: 信号强度
    func update(advertisementData: [String : Any], rssi: Int)
    
    /// 判等
    /// - Parameter object: BluetoothDeviceProtocol/CBPeripheral/UUID/String
    /// - Returns: 结果
    func isEqual(_ object: Any?) -> Bool
}

// MARK: 默认实现

public extension BluetoothDeviceProtocol {
    
    var name: String? { peripheral.name }
    
    var uuid: String { peripheral.uuidString }
    
    var services: Set<String> {
        Set(serviceCharacteristics.keys.map { $0.description })
    }
    
    var characteristics: Set<String> {
        Set(serviceCharacteristics.values.flatMap { $0 })
    }
    
    var isReady: Bool {
        characteristics.isSubset(of: disCoveredCharacteristics.map({ $0.uuidString }))
    }
    
    func getDisCoveredCharacteristic(_ uuidStr: String) -> CBCharacteristic? {
        for char in disCoveredCharacteristics {
            if char.uuidString == uuidStr {
                return char
            }
        }
        return nil
    }
    
    func update(advertisementData: [String : Any], rssi: Int) {
        self.advertisementData = advertisementData
        self.rssi = rssi
    }
}

// MARK: 判等

public extension BluetoothDeviceProtocol {
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.peripheral.identifier == rhs.peripheral.identifier
    }
    
    func isEqual(_ object: Any?) -> Bool {
        if let device = object as? Self {
            return self.peripheral.identifier == device.peripheral.identifier
        } else if let peripheral = object as? CBPeripheral {
            return self.peripheral.identifier == peripheral.identifier
        } else if let uuid = object as? UUID {
            return self.peripheral.identifier == uuid
        } else if let uuidStr = object as? String {
            return self.peripheral.identifier.uuidString == uuidStr
        } else {
            return false
        }
    }
}

// MARK: debug

public extension BluetoothDeviceProtocol {
    
    var debugDescription: String {
        name ?? "unknown"
    }
}
