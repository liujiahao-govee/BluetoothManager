//
//  ViewController.swift
//  BluetoothManager
//
//  Created by 刘嘉豪 on 2020/11/13.
//

import UIKit
import CoreBluetooth
import BluetoothManager

class ViewController: UIViewController {
    
    var cellId: String { "DiscoverDeviceCell" }
    
    lazy var tableView: UITableView = {
        let topInset: CGFloat = 60
        let table = UITableView(frame: CGRect(x: 0, y: topInset, width: view.bounds.width, height: view.bounds.height - topInset))
        table.dataSource = self
        table.delegate = self
        table.register(UINib(nibName: cellId, bundle: nil), forCellReuseIdentifier: cellId)
        table.estimatedRowHeight = 60
        table.rowHeight = UITableViewAutomaticDimension
        return table
    }()
    
    lazy var onSwitch: UISwitch = {
        let on = UISwitch(frame: CGRect(origin: CGPoint(x: 16, y: 28), size: .zero))
        on.addTarget(self, action: #selector(changeSwitch(_:)), for: .valueChanged)
        return on
    }()
    
    lazy var brightnessSlider: UISlider = {
        let slider = UISlider(frame: CGRect(origin: CGPoint(x: 80, y: 20), size: CGSize(width: 200, height: 40)))
        slider.isContinuous = false
        slider.addTarget(self, action: #selector(briSliderValueChanged(_:)), for: .valueChanged)
        slider.minimumValue = 20
        slider.maximumValue = 254
        return slider
    }()
                
    var bluetoothManager: BluetoothManager!
    
    var deviceModels: [DeviceModel] = [DeviceModel(name: "ihoment_H6005_556C"), DeviceModel(name: "2"), DeviceModel(name: "3")]
    
    weak var connectedDevice: DeviceModel?
    
    var hearbeat: Heartbeat?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bluetoothManager = BluetoothManager(delegate: self)
        
        view.addSubview(tableView)
        view.addSubview(onSwitch)
        view.addSubview(brightnessSlider)
    }
}

extension ViewController: BluetoothManagerDelegate {
    
    func didUpdateState(state: CBManagerState) {
        print(#function)
        
        if state == .poweredOn {
            bluetoothManager.startScan { $0?.contains("6005") ?? false }
        }
    }
    
    func didDiscover(device: BluetoothDeviceModel, devices: [BluetoothDeviceModel]) {
        
        print(#function, device, devices.count)
        
        guard let model = deviceModels.filter({ $0.name == device.name }).first else { return }
        model.underlyingDevice = device
                
        tableView.reloadData()
    }
    
    func didConnect(device: BluetoothDeviceModel) {
        
        print(#function, device)
    }
    
    func didFailToConnect(deviceName: String?, errorMsg: String?) {
        
        print(#function, deviceName as Any, errorMsg as Any)
        
        connectedDevice = nil
    }
    
    func didDisconnect(device: BluetoothDeviceModel, errorMsg: String?) {
        
        print(#function, device, errorMsg as Any)
        
        connectedDevice = nil
    }
    
    func didReady(device: BluetoothDeviceModel) {
        print(#function, device)
        
        guard let device = deviceModels.filter({ $0.name == device.name }).first else { return }
        connectedDevice = device
        
        hearbeat = Heartbeat(bluetoothManager, devices: [device])
        hearbeat!.fire()
    }
    
    func didUpdateValue(device: BluetoothDeviceModel, characteristic: String, data: Data) {
        print(#function, device, characteristic, NSData(data: data))
        
        guard let device = deviceModels.filter({ $0.name == device.name }).first else { return }
        
        guard data.check() else {
            return
        }
        
        let prefix: UInt8 = data[0]
        let byte1: UInt8 = data[1]
        let byte2: UInt8 = data[2]
        
        if characteristic == device.uuidTuple.read {
            if prefix == ReadEnum.prefix {
                guard let read = ReadEnum(rawValue: byte1) else { return }
                switch read {
                case .on:
                    onSwitch.setOn(byte2 == 1, animated: true)
                case .brightness:
                    brightnessSlider.setValue(Float(byte2), animated: true)
                default:
                    break
                }
            } else if prefix == WriteEnum.prefix {
                /// 控制成功返回的
            }
        }
    }
    
    func didCatchError(_ error: BMError) {
        
    }
}

extension ViewController {
    
    @objc func heartBeat() {
        
        guard let device = connectedDevice else { return }
        
        let getOn = CommandEnum.getOn.data
        let getBri = CommandEnum.getBri.data
        
        print(#function, NSData(data: getOn), NSData(data: getBri))
        
        bluetoothManager.writeDatas([(device, device.uuidTuple.write, getOn), (device, device.uuidTuple.write, getBri)])
    }
    
    @objc func changeSwitch(_ sender: UISwitch) {
        
        guard let device = connectedDevice else { return }
        
        let isOn = sender.isOn
        let data = CommandEnum.setOn(isOn).data
        
        print(#function, NSData(data: data))
        
        bluetoothManager.writeData((device, device.uuidTuple.write, data))
    }
    
    @objc func briSliderValueChanged(_ sender: UISlider) {
                
        guard let device = connectedDevice else { return }
        
        let value = UInt8(sender.value)
        let data = CommandEnum.setBri(value).data
        
        print(#function, NSData(data: data))
        
        bluetoothManager.writeData((device, device.uuidTuple.write, data))
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return deviceModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! DiscoverDeviceCell
        let device = deviceModels[indexPath.row]
        cell.device = device
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let device = deviceModels[indexPath.row]
                
        bluetoothManager.connect(device: device)
    }
}
