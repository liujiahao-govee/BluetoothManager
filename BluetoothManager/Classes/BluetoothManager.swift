//
//  BluetoothManager.swift
//  BluetoothManager
//
//  Created by 刘嘉豪 on 2020/11/14.
//

import Foundation
import CoreBluetooth

// MARK: - BluetoothManager

public final class BluetoothManager: NSObject {
    /// 为外部提供回调代理对象
    public private(set) weak var delegate: BluetoothManagerDelegate?
    /// 内部处理中央管理对象
    public private(set) var centralManager: CBCentralManager!
    /// 被发现的外设
    public private(set) var discoveredDevices: [BluetoothDeviceModel] = []
    /// 已连接的外设
    public private(set) var connectedDevices: [BluetoothDeviceModel] = []
    /// 根据外设名来过滤
    public typealias ScanFilter = ((String?) -> Bool)
    /// 外设名称过滤条件
    private var scanFilter: ScanFilter?
    /// 扫描的服务uuid
    private var scanServiceUUIDs: [CBUUID]?
    /// 扫描的附加参数
    private var scanOptions: [String : Any]?
    /// 后台进入前台是否需要恢复扫描
    private var needRecoverScan = false
    
    public init(delegate: BluetoothManagerDelegate, queue: DispatchQueue? = nil) {
        super.init()
        
        addObservers()
        
        self.delegate = delegate
        self.centralManager = CBCentralManager(delegate: self, queue: queue)
    }
}

// MARK: - Interface

public extension BluetoothManager {
    
    /// 开始扫描
    /// - Parameters:
    ///   - serviceUUIDs: 服务uuid
    ///   - options: 扫描配置
    ///   - filter: 过滤条件
    func startScan(withServices serviceUUIDs: [CBUUID]? = nil, options: [String : Any]? = nil, filter: ScanFilter? = nil) {
        scanServiceUUIDs = serviceUUIDs
        scanOptions = options
        scanFilter = filter
        
        stopScan()
        centralManager.scanForPeripherals(withServices: serviceUUIDs, options: options)
    }
    
    /// 重新扫描
    /// - Parameters:
    ///   - serviceUUIDs: 服务uuid
    ///   - options: 扫描配置
    ///   - filter: 过滤条件
    /// - 清空当前发现的设备
    func reScan(withServices serviceUUIDs: [CBUUID]? = nil, options: [String : Any]? = nil, filter: ((String?) -> Bool)? = nil) {
        /// 取消连接、停止心跳
        discoveredDevices = []
        
        startScan(withServices: serviceUUIDs, options: options, filter: filter)
    }
    
    /// 停止扫描
    func stopScan() {
        if centralManager.isScanning {
            centralManager.stopScan()
        }
    }
    
    /// 连接外设
    func connect(device: BluetoothDeviceProtocol, options: [String: Any]? = nil) {
        guard let underlyingDevice = device.underlyingDevice else { return }
        underlyingDevice.services = device.services
        underlyingDevice.characteristics = device.characteristics
        underlyingDevice.notifyCharacteristics = device.notifyCharacteristics
        underlyingDevice.serviceCharacteristics = device.serviceCharacteristics
        
        centralManager.connect(underlyingDevice.peripheral, options: options)
    }
    
    /// 断连外设
    func disconnnect(device: BluetoothDeviceProtocol) {
        guard let device = device.underlyingDevice else { return }
        centralManager.cancelPeripheralConnection(device.peripheral)
    }
    
    /// 断开全部连接
    func disconnectAll() {
        connectedDevices.forEach { self.centralManager.cancelPeripheralConnection($0.peripheral) }
    }
    
    /// 写入数据
    /// - Parameters:
    ///   - tuple: (外设, 特征, 数据)
    ///   - type: 写入类型
    func writeData(_ tuple: WriteableDataTuple, type: CBCharacteristicWriteType = .withoutResponse) {
        guard let device = tuple.device.underlyingDevice else { return }
        let uuid = tuple.characteristic
        let data = tuple.data
        guard let char = device.getDisCoveredCharacteristic(uuid) else { return }
        
        device.peripheral.writeValue(data, for: char, type: type)
    }
    
    /// 批量写入数据
    /// - Parameters:
    ///   - tuples: [(外设, 特征, 数据)]]
    ///   - type: 写入类型
    func writeDatas(_ tuples: [WriteableDataTuple], type: CBCharacteristicWriteType = .withoutResponse) {
        tuples.forEach { writeData($0, type: type) }
    }
    
    /// 读取设备信号强度
    func readRSSI(device: BluetoothDeviceProtocol) {
        guard let underlyingDevice = device.underlyingDevice else { return }
        underlyingDevice.peripheral.readRSSI()
    }
    
    /// 批量读取设备信号强度
    func readRSSI(devices: [BluetoothDeviceProtocol]) {
        devices.forEach { self.readRSSI(device: $0) }
    }
    
    /// 查看设备是否已连接
    func getDeviceIsConnected(_ device: BluetoothDeviceModel) -> Bool {
        connectedDevices.contains(device)
    }
}

private extension BluetoothManager {
    
    func matchDevice(_ peripheral: CBPeripheral, in devices: [BluetoothDeviceModel]) -> BluetoothDeviceModel? {
        for device in devices {
            if device.isEqual(peripheral) {
                return device
            }
        }
        return nil
    }
    
    /// 连接成功后即发现服务和特征并设置特征通知
    func discover(device: BluetoothDeviceModel) {
        let uuids = device.services.map { CBUUID(string: $0) }
        device.peripheral.discoverServices(uuids)
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
        
        if let device = matchDevice(peripheral, in: discoveredDevices) {
            device.update(advertisementData: advertisementData, rssi: Int(truncating: RSSI))
            delegate?.didUpdateDevice(device)
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
        
        discover(device: device)
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
            delegate?.didCatchError(.didDiscoverServicesError(device, errorMsg: BMErrorMsg.didDiscoverServicesError ?? error?.localizedDescription))
            return
        }
        
        guard let services = peripheral.services else { return }
        
        let serviceUuids = Set(services.map { $0.uuidString })
        guard device.services.isSubset(of: serviceUuids) else {
            delegate?.didCatchError(.didDiscoverServicesError(device, errorMsg: BMErrorMsg.didDiscoverServicesError ?? "服务匹配失败"))
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
            delegate?.didCatchError(.didDiscoverCharacteristicsError(device,
                                                                      service: service.uuidString,
                                                                      errorMsg: BMErrorMsg.didDiscoverCharacteristicsError ?? error?.localizedDescription))
            return
        }
        
        guard let chars = service.characteristics else { return }
        
        device.disCoveredCharacteristics = device.disCoveredCharacteristics.union(chars)
        
        let uuids = Set(chars.map { $0.uuidString })
        guard let deviceChars = device.serviceCharacteristics[service.uuidString],
              Set(deviceChars).isSubset(of: uuids) else {
            delegate?.didCatchError(.didDiscoverCharacteristicsError(device,
                                                                      service: service.uuidString,
                                                                      errorMsg: BMErrorMsg.didDiscoverCharacteristicsError ?? "特征匹配失败"))
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
            delegate?.didCatchError(.didUpdateValueError(device,
                                                          characteristic: characteristic.uuidString,
                                                          errorMsg: BMErrorMsg.didUpdateValueError ?? error?.localizedDescription))
            return
        }
        
        guard let data = characteristic.value else { return }
        
        delegate?.didUpdateValue(device: device, characteristic: characteristic.uuidString, data: data)
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        
        guard let device = matchDevice(peripheral, in: connectedDevices) else { return }
        
        guard error == nil else {
            delegate?.didCatchError(.didReadRSSIError(device, errorMsg: BMErrorMsg.didReadRSSIError ?? error?.localizedDescription))
            return
        }
        
        device.update(rssi: Int(truncating: RSSI))
        
        delegate?.didUpdateDevice(device)
    }
}
