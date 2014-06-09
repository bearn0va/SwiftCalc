//
//  Variable.swift
//  SwiftCalc
//
//  Created by Silas Schwarz on 6/8/14.
//  Copyright (c) 2014 Silas Schwarz. All rights reserved.
//

import Foundation

class Variable: Value {
    var value: String
    
    convenience init() {
        self.init(value: "")
    }
    
    init(value: String) {
        self.value = value
    }
    
    func dump() -> String {
        return "\(self.value)"
    }
    
    func verbose(indent: Int) -> String {
        return "[ Variable ] \(self.dump())"
    }
    
    func evaluate(ctx: Context) -> Value {
        if let ret = ctx.findValue(value) {
            return ret
        }
        return self
    }
}
