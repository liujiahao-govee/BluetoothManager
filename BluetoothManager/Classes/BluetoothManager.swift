//
//  BluetoothManager.swift
//  TestBluetoothKit
//
//  Created by 刘嘉豪 on 2020/11/14.
//

import Foundation
import UIKit
import CoreBluetooth

// TODO: 为设备添加心跳

// MARK: - BluetoothManager

public final class BluetoothManager: NSObject {
    
    public init(delegate: BluetoothManagerDelegate, queue: DispatchQueue? = nil) {
        super.init()
        
        addObservers()
        
        self.delegate = delegate
        self.centralManager = CBCentralManager(delegate: self, queue: queue)
    }
    
    public private(set) var centralManager: CBCentralManager!
    
    public private(set) weak var delegate: BluetoothManagerDelegate?
    
    /// 被发现的外设
    public private(set) var discoveredDevices: [BluetoothDeviceModel] = []
    
    /// 已连接的外设
    public private(set) var connectedDevices: [BluetoothDeviceModel] = []
    
    /// 外设名称过滤条件
    private var scanFilter: ((String?) -> Bool)?
    /// 扫描的服务uuid
    private var scanServiceUUIDs: [CBUUID]?
    /// 扫描的附加参数
    private var scanOptions: [String : Any]?
    /// 后台进入前台是否需要恢复扫描
    private var needRecoverScan = false
}

// MARK: - Interface

public extension BluetoothManager {
    
    /// 开始扫描
    /// - Parameters:
    ///   - serviceUUIDs: 服务uuid
    ///   - options: 扫描配置
    ///   - filter: 过滤条件
    func startScan(withServices serviceUUIDs: [CBUUID]? = nil, options: [String : Any]? = nil, filter: ((String?) -> Bool)? = nil) {
        scanServiceUUIDs = serviceUUIDs
        scanOptions = options
        scanFilter = filter
        
        centralManager.scanForPeripherals(withServices: serviceUUIDs, options: options)
    }
    
    /// 重新扫描
    /// - Parameters:
    ///   - serviceUUIDs: 服务uuid
    ///   - options: 扫描配置
    ///   - filter: 过滤条件
    /// - 清空当前发现和连接的设备（是否清空当前连接的设备待考虑）
    func reScan(withServices serviceUUIDs: [CBUUID]? = nil, options: [String : Any]? = nil, filter: ((String?) -> Bool)? = nil) {
        discoveredDevices = []
        connectedDevices = []
        
        startScan(withServices: serviceUUIDs, options: options, filter: filter)
    }
    
    /// 停止扫描
    func stopScan() {
        if centralManager.isScanning {
            centralManager.stopScan()
        }
    }
    
    /// 连接外设
    func connect(device: BluetoothDeviceModel, options: [String: Any]? = nil) {
        centralManager.connect(device.peripheral, options: options)
    }
    
    /// 断连外设
    func disconnnect(device: BluetoothDeviceModel) {
        centralManager.cancelPeripheralConnection(device.peripheral)
    }
    
    /// 发现服务和特征并设置特征通知
    /// - Parameters:
    ///   - device: 外设
    ///   - serviceCharacteristics: 服务和特征
    ///   - notityCharacteristics: 需通知的特征
    func discover(device: BluetoothDeviceModel,
                  serviceCharacteristics: ServiceCharacteristicsDict,
                  notityCharacteristics: Set<String>? = nil) {
        
        device.serviceCharacteristics = serviceCharacteristics
        device.notifyCharacteristics = notityCharacteristics ?? device.characteristics
        
        let uuids = device.services.map { CBUUID(string: $0) }
        device.peripheral.discoverServices(uuids)
    }
    
    /// 写入数据
    /// - Parameters:
    ///   - tuple: (外设, 特征, 数据)
    ///   - type: 写入类型
    func writeData(_ tuple: WriteableDataTuple, type: CBCharacteristicWriteType = .withoutResponse) {
        let device = tuple.device
        let uuid = tuple.characteristic
        let data = tuple.data
        guard let char = device.getDisCoveredCharacteristic(uuid) else { return }
        
        device.peripheral.writeValue(data, for: char, type: type)
    }
    
    /// 批量写入数据
    /// - Parameters:
    ///   - datas: [(外设, 特征, 数据)]]
    ///   - type: 写入类型
    func writeDatas(_ datas: [WriteableDataTuple], type: CBCharacteristicWriteType = .withoutResponse) {
        datas.forEach { writeData($0, type: type) }
    }
}

private extension BluetoothManager {
    
    func matchDevice(_ peripheral: CBPeripheral, in deivces: [BluetoothDeviceModel]) -> BluetoothDeviceModel? {
        for deivce in deivces {
            if deivce.isEqual(by: peripheral) {
                return deivce
            }
        }
        return nil
    }
    
    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterBackground(_:)), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive(_:)), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    @objc func didEnterBackground(_ noti: Notification) {
        if centralManager.isScanning {
            centralManager.stopScan()
            needRecoverScan = true
        }
    }
    
    @objc func didBecomeActive(_ noti: Notification) {
        if needRecoverScan {
            needRecoverScan = false
            startScan(withServices: scanServiceUUIDs, options: scanOptions, filter: scanFilter)
        }
    }
}

// MARK: - CBCentralManagerDelegate

extension BluetoothManager: CBCentralManagerDelegate {
    
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if #available(iOS 10.0, *) {
            delegate?.didUpdateState(state: central.state)
        } else {
            guard let state = CBCentralManagerState(rawValue: central.state.rawValue) else { return }
            delegate?.didUpdateState(state: state)
        }
    }
    
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        guard scanFilter?(peripheral.name) ?? true else { return }
        
        if let matched = matchDevice(peripheral, in: discoveredDevices) {
            matched.update(advertisementData: advertisementData, rssi: Int(truncating: RSSI))
            return
        }
        
        let new = BluetoothDeviceModel(peripheral: peripheral, advertisementData: advertisementData, rssi: Int(truncating: RSSI))
        discoveredDevices.append(new)
        
        delegate?.didDiscover(device: new, devices: discoveredDevices)
    }
    
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        
        guard let device = matchDevice(peripheral, in: discoveredDevices),
              matchDevice(peripheral, in: connectedDevices) == nil else { return }
            
        peripheral.delegate = self
        
        connectedDevices.append(device)
        
        delegate?.didConnect(device: device)
    }
    
    public func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        delegate?.didFailToConnect(deviceName: peripheral.name, errorMsg: error?.localizedDescription)
    }
    
    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        
        guard let device = matchDevice(peripheral, in: discoveredDevices) else { return }
        
        connectedDevices.removeAll { $0 == device }
        
        delegate?.didDisconnect(device: device, errorMsg: error?.localizedDescription)
    }
}

// MARK: - CBPeripheralDelegate

extension BluetoothManager: CBPeripheralDelegate {
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        
        guard let device = matchDevice(peripheral, in: connectedDevices) else { return }
        
        guard error == nil else {
            delegate?.didCatchError(.didDiscoverServicesFailed(device, error: error!))
            return
        }
        
        guard let services = peripheral.services else { return }
        
        let serviceUuids = Set(services.map { $0.uuidString })
        guard device.services.isSubset(of: serviceUuids) else {
            delegate?.didCatchError(.didDiscoverServicesFailed(device, error: "服务匹配失败"))
            return
        }
        
        services.forEach { (service) in
            guard let characteristics = device.serviceCharacteristics[service.uuidString] else { return }
            let uuids = characteristics.map { CBUUID(string: $0) }
            peripheral.discoverCharacteristics(uuids, for: service)
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        guard let device = matchDevice(peripheral, in: connectedDevices) else { return }
        
        guard error == nil else {
            delegate?.didCatchError(.didDiscoverCharacteristicsFailed(device, service: service.uuidString, error: error!))
            return
        }
        
        guard let chars = service.characteristics else { return }
        
        device.disCoveredCharacteristics = device.disCoveredCharacteristics.union(chars)
        
        let uuids = Set(chars.map { $0.uuidString })
        guard let deviceChars = device.serviceCharacteristics[service.uuidString],
              Set(deviceChars).isSubset(of: uuids) else {
            delegate?.didCatchError(.didDiscoverCharacteristicsFailed(device, service: service.uuidString, error: "特征匹配失败"))
            return
        }
        
        chars.forEach { (char) in
            if device.notifyCharacteristics.contains(char.uuidString) {
                peripheral.setNotifyValue(true, for: char)
            }
        }
        
        if device.isReady {
            delegate?.didReady(device: device)
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
        guard let device = matchDevice(peripheral, in: connectedDevices) else { return }
        
        guard error == nil else {
            delegate?.didCatchError(.didUpdateValueFailed(device, characteristic: characteristic.uuidString, error: error!))
            return
        }
        
        guard let data = characteristic.value else { return }
        
        delegate?.didUpdateValue(device: device, characteristic: characteristic.uuidString, data: data)
    }
}
