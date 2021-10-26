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
    
    /// 数据包（补全+校验）
    /// - Parameters:
    ///   - bytes: 0x00, 0x01, 0x02...
    ///   - length: 包长度，自动补0
    ///   - rule: 校验规则
    public init(_ bytes: Byte..., fill length: Int = 20, check rule: CheckRule = .crc) {
        self.init(bytes)
        self.fill(length: length, check: rule)
    }
    
    /// 数据补全
    /// - Parameters:
    ///   - length: 目标长度
    ///   - rule: 校验规则
    public mutating func fill(length: Int = 20, check rule: CheckRule = .crc) {
        assert(count < length, "count must < fill length")
        var data = self
        let fillLength = length - 1 - count
        if fillLength > 0 {
            let fillData = Data(repeating: 0, count: fillLength)
            data.append(fillData)
        }
        data.append(rule.check(self))
        self = data
    }
    
    /// 校验数据包
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
    
    /// 长包分割成多包
    /// packetSize 入参 head&end 通过(Byte)->Data来定参
    public func divide() -> [Data] {
        let headSize = 14
        let bodySize = 17
        let endSize = 17
        var bodyCount = 0
        
        let remainDataCount = count - headSize - endSize
        if remainDataCount > 0 {
            bodyCount = Int(ceil(Double(remainDataCount) / Double(bodySize)))
        }
        
        let packetCount: Int = 1 + bodyCount + 1
        guard packetCount <= 0xff else {
            return []
        }
        
        var head = Data([0xa3, 0x00, 0x01, Byte(packetCount), 0x02])
        var bodys: [Data] = []
        var end = Data([0xa3, 0xff])
        
        for i in 0..<packetCount {
            if i == 0 {
                let startIndex = 0
                let endIndex = Swift.min(headSize, count) - 1
                let headRemain = self[startIndex...endIndex]
                head.append(headRemain)
                head.fill()
            } else if i == packetCount - 1 {
                let startIndex = headSize + (i - 1) * bodySize
                let endIndex = startIndex + Swift.min(endSize, count - startIndex - 1)
                if endIndex >= startIndex {
                    let endRemain = self[startIndex...endIndex]
                    end.append(endRemain)
                }
                end.fill()
            } else {
                let startIndex = headSize + (i - 1) * bodySize
                let endIndex = startIndex + bodySize - 1
                var body = Data([0xa3, Byte(i)])
                let bodyRemain = self[startIndex...endIndex]
                body.append(bodyRemain)
                body.fill()
                bodys.append(body)
            }
        }
        
        return [head] + bodys + [end]
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
