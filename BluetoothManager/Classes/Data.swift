//
//  Data.swift
//  BluetoothManager
//
//  Created by 刘嘉豪 on 2020/11/14.
//

import Foundation

/// 字节
public typealias Byte = UInt8

extension Byte {
    
    /// 高低4位字节
    /// - Parameters:
    ///   - high: 高4位字节
    ///   - low: 低4位字节
    /// - Returns: 字节
    static public func four(high: Byte, low: Byte) -> Byte {
        var byte: Byte = 0
        byte ^= (high << 4)
        byte ^= low
        print(String(byte, radix: 2, uppercase: true))
        return byte
    }
}

extension Data {
    
    /// 数据包
    /// - Parameters:
    ///   - bytes: 0x00, 0x01, 0x02...
    ///   - length: 包长度，自动补0
    ///   - rule: 校验规则
    public init(_ bytes: Byte..., fill length: Int = 20, check rule: CheckRule = .crc) {
        assert(bytes.count < length, "init data error: bytes.count must < length")
        self.init(repeating: 0, count: length)
        for (index, byte) in bytes.enumerated() {
            self[index] = byte
        }
        self[length - 1] = rule.check(self)
    }
    
    /// 检查数据包
    /// - Parameter lenght: 包长度
    /// - Parameter rule: 校验规则
    /// - Returns: 是否有效
    public func check(_ lenght: Int = 20, check rule: CheckRule = .crc) -> Bool {
        guard count == lenght else {
            return false
        }
        let temp = prefix(lenght - 1)
        return rule.check(temp) == self.last
    }
}

extension Data {
    
    public var debugDescription: String {
        NSData(data: self).debugDescription
    }
}

/// 校验规则
public enum CheckRule {
    
    public typealias Check = (Data) -> Byte
    
    case crc
    
    public var check: Check {
        switch self {
        case .crc:
            return {
                var c: Byte = 0
                for (i, n) in $0.enumerated() {
                    i == 0 ? (c = Byte(n)) : (c ^= Byte(n))
                }
                return c
            }
        }
    }
}
