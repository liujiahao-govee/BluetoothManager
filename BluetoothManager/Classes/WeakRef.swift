//
//  WeakRef.swift
//  TestBluetoothKit
//
//  Created by 刘嘉豪 on 2020/11/14.
//

import Foundation

public final class WeakRef<T> where T: AnyObject {
    
    private(set) weak var value: T?
    
    init(_ value: T?) {
        self.value = value
    }
}
