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
    var count = 0
    
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
        return Simple(value: named)
    }
}
