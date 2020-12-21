//
//  DiscoverDeviceCell.swift
//  BluetoothManager
//
//  Created by 刘嘉豪 on 2020/11/13.
//

import UIKit
import BluetoothManager

class DiscoverDeviceCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var uuidLabel: UILabel!
    @IBOutlet weak var dataLabel: UILabel!
    @IBOutlet weak var rssiLabel: UILabel!
    
    var device: DeviceModel! {
        didSet {
            nameLabel.text = device.name
            dataLabel.text = "\(String(describing: device.underlyingDevice?.advertisementData))"
            rssiLabel.text = "\(String(describing: device.underlyingDevice?.rssi))"
            uuidLabel.text = device.underlyingDevice?.uuid
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
