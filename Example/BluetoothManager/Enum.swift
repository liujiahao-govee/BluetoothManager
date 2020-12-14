//
//  Enum.swift
//  BluetoothManager
//
//  Created by 刘嘉豪 on 2020/11/14.
//

import Foundation

enum CommandEnum {
    
    typealias Read = ReadEnum
    typealias Write = WriteEnum
    
    case getOn
    case setOn(_ flag: Bool)
    
    case getBri
    case setBri(_ value: UInt8)
    
    var data: Data {
        switch self {
        case .getOn:
            return Data(Read.prefix, Read.on.rawValue)
        case .setOn(let flag):
            return Data(Write.prefix, Write.on.rawValue, flag ? 0x01 : 0x00)
        case .getBri:
            return Data(Read.prefix, Read.brightness.rawValue)
        case .setBri(let value):
            return Data(Write.prefix, Write.brightness.rawValue, value)
        }
    }
}

protocol CommandByte {
    static var prefix: UInt8 { get }
    var byte: UInt8 { get }
}

enum ReadEnum: UInt8 {
    case on = 0x01
    case brightness = 0x04
    case mode = 0x05
    case softwareVersion = 0x06
    case deviceInfo = 0x07
    case sleep = 0x11
    case wake = 0x12
    case diy = 0x0a
    case timing = 0x23
    case protocolVersion = 0xEF
    
    enum DeviceInfoEnum: UInt8 {
        case deviceId = 0x02
        case hardwareVersion = 0x03
        case mac = 0x06
    }
    
    static var prefix: UInt8 { 0xaa }
}

enum WriteEnum: UInt8 {
    case on = 0x01
    case brightness = 0x04
    case mode = 0x05
    case syncTime = 0x09
    case sleep = 0x11
    case wake = 0x12
    case timing = 0x23
    case test = 0xff
    
    static var prefix: UInt8 { 0x33 }
}
