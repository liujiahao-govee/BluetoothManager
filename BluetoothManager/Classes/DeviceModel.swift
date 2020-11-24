//
//  DeviceModel.swift
//  TestBluetoothKit
//
//  Created by 刘嘉豪 on 2020/11/14.
//

import Foundation
import CoreBluetooth

/// [服务: [特征]]
public typealias ServiceCharacteristicsDict = [String: [String]]
/// (外设, 特征, 数据)
public typealias WriteableDataTuple = (device: BluetoothDeviceModel, characteristic: String, data: Data)

public class BluetoothDeviceModel {
    
    /// 考虑下，如何嵌套业务数据，比如SKU，等等，一些用户自定义参数
    /// 可以用一个模型来包含这个模型，然后就可以在外部随意添加了，是个方法。
    
    public let peripheral: CBPeripheral
    public var advertisementData: [String : Any]
    public var rssi: Int
    
    public init(peripheral: CBPeripheral, advertisementData: [String : Any], rssi: Int) {
        self.peripheral = peripheral
        self.advertisementData = advertisementData
        self.rssi = rssi
    }
    
    /// 服务: [特征]
    public var serviceCharacteristics: ServiceCharacteristicsDict = ServiceCharacteristicsDict()
    /// 需要通知的特征
    public var notifyCharacteristics: Set<String> = []
    /// 发现的特征
    public var disCoveredCharacteristics: Set<CBCharacteristic> = []
}

public extension BluetoothDeviceModel {
    
    /// 外设名
    var name: String? { peripheral.name }
    
    /// 外设uuid
    var uuid: String { peripheral.uuidString }
    
    /// 外设服务
    var services: Set<String> {
        return Set(serviceCharacteristics.keys.map { $0.description })
    }
    
    /// 外设特征
    var characteristics: Set<String> {
        return Set(serviceCharacteristics.values.flatMap { $0 })
    }
    
    /// 外设是否准备完毕（服务和特征都已匹配）
    var isReady: Bool {
        characteristics.isSubset(of: disCoveredCharacteristics.map({ $0.uuidString }))
    }
    
    /// 根据uuid获取已发现的特征
    /// - Parameter uuidStr: 特征uuid
    /// - Returns: 发现的特征
    func getDisCoveredCharacteristic(_ uuidStr: String) -> CBCharacteristic? {
        for char in disCoveredCharacteristics {
            if char.uuidString == uuidStr {
                return char
            }
        }
        return nil
    }
    
    /// 更新设备数据
    /// - Parameters:
    ///   - advertisementData: 广播数据
    ///   - rssi: 信号强度
    func update(advertisementData: [String : Any], rssi: Int) {
        self.advertisementData = advertisementData
        self.rssi = rssi
    }
}

extension BluetoothDeviceModel: Equatable {
    
    public static func == (lhs: BluetoothDeviceModel, rhs: BluetoothDeviceModel) -> Bool {
        lhs.peripheral.identifier == rhs.peripheral.identifier
    }
    
    public func isEqual(by peripheral: CBPeripheral) -> Bool {
        self.peripheral.identifier == peripheral.identifier
    }
}

extension BluetoothDeviceModel: CustomDebugStringConvertible {
    
    public var debugDescription: String {
        return (name ?? "nil") + "\(advertisementData)" + "\(rssi)"
    }
}
