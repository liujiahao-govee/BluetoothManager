//
//  CBExtension+UuidStrings.swift
//  TestBluetoothKit
//
//  Created by 刘嘉豪 on 2020/11/16.
//

import Foundation
import CoreBluetooth

extension CBPeripheral {
    var uuidString: String { identifier.uuidString }
}

extension CBService {
    var uuidString: String { uuid.uuidString }
}

extension CBCharacteristic {
    var uuidString: String { uuid.uuidString }
}
