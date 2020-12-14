//
//  Data.swift
//  BluetoothManager
//
//  Created by 刘嘉豪 on 2020/11/14.
//

import Foundation

public typealias Byte = UInt8

extension Data {
    
    /// 数据包
    /// - Parameters:
    ///   - hexs: 0x00, 0x01, 0x02...
    ///   - length: 包长度，自动补0
    public init(_ hexs: Byte..., fill length: Int = 20) {
        self.init()
        hexs.forEach { self.append($0) }
        self.fill(length)
    }
    
    /// 检查数据包
    /// - Parameter lenght: 包长度
    /// - Returns: 是否有效
    public func check(_ lenght: Int = 20) -> Bool {
        guard count == lenght else {
            return false
        }
        let temp = prefix(lenght - 1)
        return temp.checked == self.last
    }
    
    mutating func fill(_ length: Int = 20) {
        let remain = length - 1 - count
        if remain > 0 {
            append(Data(repeating: 0, count: remain))
        }
        append(checked)
    }
    
    var checked: Byte {
        var c: Byte = 0
        for (i, n) in enumerated() {
            if i == 0 {
                c = Byte(n)
            } else {
                c ^= Byte(n)
            }
        }
        return c
    }
}
