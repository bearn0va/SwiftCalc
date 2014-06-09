//
//  Fraction.swift
//  SwiftCalc
//
//  Created by Silas Schwarz on 6/8/14.
//  Copyright (c) 2014 Silas Schwarz. All rights reserved.
//

import Foundation

class Fraction: Value {
    var numerator: Int
    var denominator: Int
    
    convenience init() {
        self.init(numerator: 0, denominator: 1)
    }
    
    init(numerator: Int, denominator: Int) {
        self.numerator = numerator
        self.denominator = denominator
        self.simplify()
    }
    
    func dump() -> String {
        var expr = Expression(type: .Divide, left: Simple(value: numerator), right: Simple(value: denominator))
        return expr.dump()
    }
    
    func verbose(indent: Int) -> String {
        var expr = Expression(type: .Divide, left: Simple(value: numerator), right: Simple(value: denominator))
        return expr.verbose(indent)
    }
    
    func evaluate(ctx: Context) -> Value {
        self.simplify()
        if denominator != 1 {
            return self
        } else {
            return Simple(value: numerator)
        }
    }
    
    func simplify() {
        let d = gcf(numerator, denominator)
        numerator /= d
        denominator /= d
        if denominator < 0 {
            numerator = -numerator
            denominator = -denominator
        }
    }
}

func gcf(a: Int, b: Int) -> Int {
    return a % b == 0 ? a : gcf(b, a % b)
}
