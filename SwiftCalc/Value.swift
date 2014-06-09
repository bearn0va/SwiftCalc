//
//  Value.swift
//  SwiftCalc
//
//  Created by Silas Schwarz on 6/7/14.
//  Copyright (c) 2014 Silas Schwarz. All rights reserved.
//

import Foundation

protocol Value {
    func dump() -> String
    func verbose(indent: Int) -> String
    func evaluate(ctx: Context) -> Value
}

class Simple<T>: Value {
    var _value = T[]()
    var value: T {
    get {
        return _value[0]
    }
    set {
        if _value.count != 0 {
            _value[0] = newValue
        } else {
            _value += newValue
        }
    }
    }
    
    convenience init() {
        self.init(value: 0 as T)
    }
    
    init(value: T) {
        self._value += value
    }
    
    func dump() -> String {
        return "\(self._value[0])"
    }
    
    func verbose(indent: Int) -> String {
        return "[ Simple ] \(self.dump())"
    }
    
    func evaluate(ctx: Context) -> Value {
        return self
    }
}
