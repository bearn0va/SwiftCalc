//
//  Context.swift
//  SwiftCalc
//
//  Created by Silas Schwarz on 6/8/14.
//  Copyright (c) 2014 Silas Schwarz. All rights reserved.
//

import Foundation

class Context {
    var locals = Dictionary<String, Value>[]()
    var count: Int = -1
    
    init() {
        self.newLocals()
    }
    
    func newLocals() {
        count += 1
        self.locals.insert(Dictionary<String, Value>(), atIndex: 0)
    }
    
    func popLocals() {
        count -= 1
        self.locals.removeAtIndex(0)
    }
    
    func findValue(named: String) -> Value? {
        for local in locals {
            if let value = local[named] {
                return value
            }
        }
        return Variable(value: named)
    }
    
    func setLocal(value: Value, name: String) {
        locals[0][name] = value
    }
    
    func setGlobal(value: Value, name: String) {
        locals[count][name] = value
    }
}
