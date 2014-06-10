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
    
    func arithmatic(type: ExpressionType, b: Value, reverse: Bool = false) -> Value {
        if let _b = b as? Simple<Int> {
            switch type {
            case .Add:
                return Fraction(numerator: self.numerator + _b.value * self.denominator, denominator: self.denominator)
            case .Subtract:
                if reverse {
                    return Fraction(numerator: _b.value * self.denominator - self.numerator, denominator: self.denominator)
                }
                return Fraction(numerator: self.numerator - _b.value * self.denominator, denominator: self.denominator)
            case .Multiply:
                var ret: Fraction = Fraction(numerator: self.numerator * _b.value, denominator: self.denominator)
                if ret.denominator == 1 {
                    return Simple(value: ret.numerator)
                }
                return ret
            case .Divide:
                if reverse {
                    return Fraction(numerator: self.denominator * _b.value, denominator: self.numerator)
                }
                return Fraction(numerator: self.numerator, denominator: self.denominator * _b.value)
            case .Power:
                if reverse {
                    return Expression(type: type, left: Simple(value: self.asFloat()), right: _b)
                }
                return Fraction(numerator: power(self.numerator, _b.value), denominator: power(self.numerator, _b.value))
            default:
                return Error()
            }
        } else if let _b = b as? Simple<Float> {
            return Expression(type: type, left: Simple(value: self.asFloat()), right: _b)
        } else if let _b = b as? Fraction {
            if reverse {
                return _b.arithmatic(type, b: self, reverse: false)
            }
            switch type {
            case .Add:
                return Fraction(numerator: self.numerator * _b.denominator + _b.numerator * self.denominator, denominator: self.denominator * _b.denominator)
            case .Subtract:
                return Fraction(numerator: self.numerator * _b.denominator - _b.numerator * self.denominator, denominator: self.denominator * _b.denominator)
            case .Multiply:
                return Fraction(numerator: self.numerator * _b.numerator, denominator: self.denominator * _b.denominator)
            case .Divide:
                return Fraction(numerator: self.numerator * _b.denominator, denominator: self.denominator * _b.numerator)
            case .Power:
                return Expression(type: type, left: Simple(value: self.asFloat()), right: Simple(value: _b.asFloat()))
            default:
                return Error()
            }
        }
        return Error()
    }
    
    func asFloat() -> Float {
        var n: Float = (self.numerator as NSNumber).floatValue
        var d: Float = (self.numerator as NSNumber).floatValue
        return n / d
    }
}

func gcf(a: Int, b: Int) -> Int {
    return a % b == 0 ? b : gcf(b, a % b)
}
